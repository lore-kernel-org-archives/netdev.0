From: Ben Greear <greearb@candelatech.com>
Subject: Re: Poor gige performance with 2.4.20-pre*
Date: Sat, 28 Sep 2002 19:32:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D966656.7040205@candelatech.com>
References: <200209282257.g8SMvta32527@vindaloo.ras.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Gooch <rgooch@ras.ucalgary.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Gooch wrote:
>   Hi, all. For a while now I've noticed poor performance with gige
> cards under 2.4.19 and 2.4.20-pre*. At first I thought it was because
> of the cheap-ass Addtron cards I bought (these use the ns83820 chip).
> But now that the Intel E1000 cards are pretty cheap too, I've grabbed
> a couple (part number: PWLA8390MT) and see the same problem. In fact,
> the E1000 cards are no better than the Addtron cards. I'm using the
> D-Link DGS-1008T 8-port gige switch. MTU=1500 bytes.

Machine: dual Athlon, 1.66Ghz, 64/66Mhz pci, 512MB RAM,
   2 Intel PRO/1000 MT server NICs.
   Kernel: 2.4.20-pre7, pre8 (same behaviour)

I was able to send and
receive 400Mbps between two cards on the machine simultaneously.
This is sustained over a period of time untill the box crashes
after an hour or so :(

Using pktgen, I could generate 860Mbps in one direction from one port
to another on the same machine (crashed after an hour or so here too).

Try setting the TxDescriptors=4096 RxDescriptors=1024 when loading the
e1000 module, that helps tremendously when using smaller packets.

I tried the e1000 driver in 2.5.38 on the machine, it ran at about 1/3 of
the speed, and crashed in under 5 minutes...

So, the performance could be better, but what is really killing me is
stability at this point...

> 
> The basic test I do is to send 100 MB over a TCP connection from one
> machine to the other. The results are:
> 
> Dual PIII 450 MHz -> Dual Athalon 1.6 GHz yields 58 MB/s
> Dual Athalon 1.6 GHz -> Dual PIII 450 MHz yields 23 MB/s
> 
> This is quite a bit less than what gige is supposed to give. Is this
> expected?
> 
> 				Regards,
> 
> 					Richard....
> Permanent: rgooch@atnf.csiro.au
> Current:   rgooch@ras.ucalgary.ca
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
