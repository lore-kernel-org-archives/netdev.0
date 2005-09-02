From: Guillaume Autran <gautran@mrv.com>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x
 kernels
Date: Fri, 02 Sep 2005 12:18:52 -0400
Message-ID: <43187B6C.7020203@mrv.com>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu> <43184D79.6040009@mrv.com> <20050902135256.GC12617@yakov.inr.ac.ru> <43185E81.2070300@mrv.com> <20050902154424.GA15060@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20050902154424.GA15060@yakov.inr.ac.ru>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexey,

Do you think this will also fix Ion's issue with small window size never 
going back up ?

Thanks
Guillaume.

Alexey Kuznetsov wrote:

>Hello!
>
>  
>
>>Here are the dumps...
>>    
>>
>
>I see. It has nothing to do with clamping. Indeed this is a very old bug.
>Frankly speaking I even was aware about this at some moment
>(so that if the sender was Linux it would not happen. It was fixed there. :-))
>
>With such small window sender is forced to send a tiny segment
>via SWS override timer and receiver is confused in believing this
>is sender's mss, so the result is broken SWS avoidance.
>
>I think you can cure it deleting the following lines:
>
>                    /* If PSH is not set, packet should be
>                     * full sized, provided peer TCP is not badly broken.
>                     * This observation (if it is correct 8)) allows
>                     * to handle super-low mtu links fairly.
>                     */
>                    (len >= TCP_MIN_MSS + sizeof(struct tcphdr) &&
>                     !(tcp_flag_word(skb->h.th)&TCP_REMNANT))) {
>
>
>in tcp_input.c:tcp_measure_rcv_mss() at receiver side.
>
>
>Alexey
>
>  
>

-- 
=======================================
Guillaume Autran
Senior Software Engineer
MRV Communications, Inc.
Tel: (978) 952-4932 office
E-mail: gautran@mrv.com
======================================= 


