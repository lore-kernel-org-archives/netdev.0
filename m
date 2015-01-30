From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 30 Jan 2015 05:19:35 -0800
Message-ID: <1422623975.21689.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54CB5D08.2070906@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	eyalpe-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54CB5D08.2070906-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-01-30 at 11:29 +0100, Arend van Spriel wrote:

> Hi Eric,
> 
> Your suggestions are still based on the fact that you consider wireless 
> networking to be similar to ethernet, but as Michal indicated there are 
> some fundamental differences starting with CSMA/CD versus CSMA/CA. Also 
> the medium conditions are far from comparable. There is no shielding so 
> it needs to deal with interference and dynamically drops the link rate 
> so transmission of packets can take several milliseconds. Then with 11n 
> they came up with aggregation with sends up to 64 packets in a single 
> transmit over the air at worst case 6.5 Mbps (if I am not mistaken). The 
> parameter value for tcp_limit_output_bytes of 131072 means that it 
> allows queuing for about 1ms on a 1Gbps link, but I hope you can see 
> this is not realistic for dealing with all variances of the wireless 
> medium/standard. I suggested this as topic for the wireless workshop in 
> Otawa [1], but I can not attend there. Still hope that there will be 
> some discussions to get more awareness.

Ever heard about bufferbloat ?

Have you read my suggestions and tried them ?

You can adjust the limit per flow to pretty much you want. If you need
64 packets, just do the math. If in 2018 you need 128 packets, do the
math again.

I am very well aware that wireless wants aggregation, thank you.

131072 bytes of queue on 40Gbit is not 1ms, but 26 usec of queueing, and
we get line rate nevertheless.

We need this level of shallow queues (BQL, TSQ), to get very precise rtt
estimations so that TCP has good entropy for its pacing, even in the 50
usec rtt ranges.

If we allowed 1ms of queueing, then a 40Gbit flow would queue 5 MBytes.

This was terrible, because it increased cwnd and all sender queues to
insane levels.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
