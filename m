From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] tun: don't zeroize sock->file on detach
Date: Wed, 08 Aug 2012 14:34:10 -0700 (PDT)
Message-ID: <20120808.143410.991859746378752444.davem@davemloft.net>
References: <20120711114753.24395.53193.stgit@localhost6.localdomain6>
	<50226147.3010309@parallels.com>
	<CAK6E8=cpODYa1xURk7BZBnWwx5q3OD8-xkCau7GNPn+1BS0oQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skinsbursky@parallels.com, netdev@vger.kernel.org,
	ruanzhijie@hotmail.com, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
To: ycheng@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=cpODYa1xURk7BZBnWwx5q3OD8-xkCau7GNPn+1BS0oQQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 8 Aug 2012 10:48:32 -0700

> On Wed, Aug 8, 2012 at 5:53 AM, Stanislav Kinsbursky
> <skinsbursky@parallels.com> wrote:
>> Hi, Dave.
>> What about this patch?
>>
>>
>> On Wed, Jul 11, 2012 at 03:48:20PM +0400, Stanislav Kinsbursky wrote:
>>>
>>> This is a fix for bug, introduced in 3.4 kernel by commit
>>> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things,
>>> replaced
>>> simple sock_put() by sk_release_kernel(). Below is sequence, which leads
>>> to
>>> oops for non-persistent devices:
>>>
>>> tun_chr_close()
>>> tun_detach()                            <== tun->socket.file = NULL
>>> tun_free_netdev()
>>> sk_release_sock()
>>> sock_release(sock->file == NULL)
>>> iput(SOCK_INODE(sock))                  <== dereference on NULL pointer
>>>
>>> This patch just removes zeroing of socket's file from __tun_detach().
>>> sock_release() will do this.
>>>
>>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> 
> I has tested this patch and it works (so my kernel stops crashing
> using tun devices).

This patch needs to be formally resubmitted to netdev.
