From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 5/5] epoll: Add busy poll support to epoll with
 socket fds.
Date: Thu, 16 Mar 2017 15:38:39 -0700
Message-ID: <CAKgT0UfwxL4tG+XJAsqx+AW_LtMuLCqYZYh+uJXRnYN13MTXJA@mail.gmail.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
 <20170316183302.15806.2645.stgit@localhost.localdomain> <1489702304.28631.251.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489702304.28631.251.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 3:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-16 at 11:33 -0700, Alexander Duyck wrote:
>> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
>
>> +/*
>> + * If busy polling is on and the file is a socket, return a pointer to
>> + * struct sock
>> + */
>> +static inline struct sock *ep_sk_from_file(struct file *file)
>> +{
>> +     struct inode *inode = file_inode(file);
>> +
>> +     if (!S_ISSOCK(inode->i_mode))
>> +             return NULL;
>> +
>> +     return ((struct socket *)file->private_data)->sk;
>> +}
>
> I believe a more standard way is to use sock_from_file()
>
> (This does not have to fetch a cache line to read i_mode ))

Thanks.  Will make sure to update to use that for v2.

- Alex
