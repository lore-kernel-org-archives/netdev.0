From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Thu, 26 Sep 2002 18:30:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D93B4CB.8040905@candelatech.com>
References: <200209270100.FAA19447@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>The old way is broken, it sets the bound-device to 0 when sending
>>the syn-ack.
> 
> 
> Ben, this function is _not_ used to send syn-acks...

I am not so sure, untill I changed that method, it most certainly
did not work.  It could have been something other than the syn-ack
that failed though...

Unfortunately, I ripped out all of the printks, so I cannot easily back
up my claims w/out poluting the code again.

> 
> 
> 
>>+#ifdef CONFIG_NET_SENDTOSELF
>>+	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), sk->bound_dev_if))
>>+#else
>>  	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), 0))
>>+#endif
> 
> 
> This chunk is noop, sk here is a dummy socket internal to kernel,
> where sk->bound_dev_if is identical zero. Grep code to see
> what it is used for.

Think about this:  Suppose you are connecting to a listening socket that has been
bound to a device.  That creates the the temporary socket structure
on the receive side, which
is used to send the syn-ack.  That temp socket structure must also be
bound to the same device, or the ack will not get routed correctly
back out of the right interface.

As far as I can tell, the code must be patched as above or the temp socket
will not use the correct bound device.  Please explain how the syn-ack
can get routed based on the parent's bound_dev_if if my assumption here is
not correct.

> 
> The same ("noopness") is true about 90% of the patch. F.e. all the messing
> inside tcp with openreqs is noop.
> 
> Essentially, the only chunk which has a real meaning is that one
> for fib_frontend.c. And it is simpler to do this with sysctl, compare
> to rp_filter at al.

I will investigate that code...I haven't used sysctl on purpose before :)

Thanks for the review, and I look forward to your response to my
assertions!

Ben

> 
> Alexey
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
