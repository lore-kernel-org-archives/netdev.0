From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 22:50:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414DF11C.1080505@eurodev.net>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040919120249.GA5963@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Sun, Sep 19, 2004 at 05:58:52PM +1000, Herbert Xu wrote:
>  
>
>>Besides, for any netlink socket but the first for a process, they'll
>>all have negative pid's which have nothing to do with the real pid.
>>So I really think that the wake_up_process hunk is bogus.
>>    
>>
>
>Another reason why this is bogus.
>
>Most kernel users of unicast have a send timeout setting of 0.  Therefore
>your wake_up_process() call will never happen when netlink_attachskb is
>called by the kernel.
>  
>

Yes, I didn't modify MSG_DONTWAIT + unicast behaviour and I've never 
wanted to. Actually my patch is not addressed to that case, my intention 
is improving netlink socket with when sending a lot of information from 
kernel to user in a short time, in this case socket overruns easily.

Which are those applications? for example, netfilter modules like 
ip_queue and ipt_ULOG. Even more, these applications are in interrupt 
context and, if I'm not wrong, I realized that there's some problems 
using netlink sockets in this context, for example, see netlink_ack 
allocating a skb with GFP_KERNEL flag, it hits a bug slab.

>Worse still, previously if a netlink request blocked indefinitely it
>only did that in the context of the calling process.  Now it'll
>dead-lock the entire system because you're using the generic work
>queue.
>
Hebert, I don't see such case, please could you detail it a bit more?

regards,
Pablo
