From: Ben Greear <greearb@candelatech.com>
Subject: Re: Poor gige performance with 2.4.20-pre*
Date: Sun, 29 Sep 2002 12:32:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D975556.5070706@candelatech.com>
References: <200209282257.g8SMvta32527@vindaloo.ras.ucalgary.ca>	<3D966656.7040205@candelatech.com> <200209291922.g8TJMA312403@vindaloo.ras.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Gooch <rgooch@ras.ucalgary.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Gooch wrote:
> Ben Greear writes:
> 
>>Richard Gooch wrote:
>>
>>>  Hi, all. For a while now I've noticed poor performance with gige
>>>cards under 2.4.19 and 2.4.20-pre*. At first I thought it was because
>>>of the cheap-ass Addtron cards I bought (these use the ns83820 chip).
>>>But now that the Intel E1000 cards are pretty cheap too, I've grabbed
>>>a couple (part number: PWLA8390MT) and see the same problem. In fact,
>>>the E1000 cards are no better than the Addtron cards. I'm using the
>>>D-Link DGS-1008T 8-port gige switch. MTU=1500 bytes.
>>
>>Try setting the TxDescriptors=4096 RxDescriptors=1024 when loading the
>>e1000 module, that helps tremendously when using smaller packets.
> 
> 
> Didn't help at all. Just to summarise, I've got:
> options e1000 TxDescriptors=4096 RxDescriptors=1024
> net.ipv4.tcp_rmem = 262144 262144 262144
> net.ipv4.tcp_wmem = 262144 262144 262144
> MTU=1500
> 
> I'm doing read(2)/write(2) to/from a user-space buffer over a TCP
> socket with 256 KiB buffer size.
> 
> Is the E1000 supposed to have hardware interrupt mitigation (thus
> avoiding the need for NAPI)?

NAPI did not greatly improve the performance I saw with larger packets,
but it did help with smaller (say, 60 byte) packets.

One other thing I saw with TCP connections:  They started off slow, but after
a few seconds they were reacing their peak throughput.  How long are you running
your test?

Ben

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
