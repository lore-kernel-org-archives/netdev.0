From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Wed, 06 Apr 2005 09:23:15 -0700
Message-ID: <42540CF3.7070501@cs.wisc.edu>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Dmitry Yusupov <dmitry_yus@yahoo.com> wrote:
>>* netlink alloc_skb() now uses sk_allocation instead of hard-coded
>>GFP_KERNEL
> 
> 
> Why? We never set it to anything else for netlink.
> 

It is due to where it is being used. open-iscsi uses netlink
sockets for communication in a block (scsi specificically)
driver that has pushed much of its code to usersapce. Forcing
open-iscsi to use GFP_KERNEL causes a couple of problems. The
worst would be where a GFP_KERNEL allocation causes a write,
and that write is to an iscsi disk that open-iscsi is managing.
The write could then hit the same code path and cause another
GFP_KERNEL allocation and we could loop like that until the
system locks up.
