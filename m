From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Add sockaddr length checks before accessing
 sa_family in bind and connect handlers
Date: Thu, 08 Jun 2017 16:04:25 -0400 (EDT)
Message-ID: <20170608.160425.3981801836671654.davem@davemloft.net>
References: <20170608091336.8274-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        viro@zeniv.linux.org.uk, keescook@chromium.org,
        mszeredi@redhat.com, iboukris@gmail.com, avagin@openvz.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mjurczyk@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608091336.8274-1-mjurczyk@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mateusz Jurczyk <mjurczyk@google.com>
Date: Thu,  8 Jun 2017 11:13:36 +0200

> Verify that the caller-provided sockaddr structure is large enough to
> contain the sa_family field, before accessing it in bind() and connect()
> handlers of the AF_UNIX socket. Since neither syscall enforces a minimum
> size of the corresponding memory region, very short sockaddrs (zero or
> one byte long) result in operating on uninitialized memory while
> referencing .sa_family.
> 
> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>

The sockaddr comes from a structure on the caller's kernel stack, even
if the user gives a smaller length, it is legal to access that memory.
