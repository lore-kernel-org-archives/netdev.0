From: Ben Greear <greearb@candelatech.com>
Subject: Re: SCTP and IP_TOS
Date: Mon, 12 Aug 2013 13:51:54 -0700
Message-ID: <52094AEA.9090904@candelatech.com>
References: <52091492.9060904@candelatech.com> <520943E2.7010408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36296 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab3HLUv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 16:51:56 -0400
In-Reply-To: <520943E2.7010408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2013 01:21 PM, Vlad Yasevich wrote:
> On 08/12/2013 01:00 PM, Ben Greear wrote:
>> Hello!
>>
>> I notice that I read 0x2 as IP_TOS getsockopt on an SCTP socket configured
>> for streaming mode.
>>
>> Looks to me like the reason is that SCTP uses a socket type of
>> SCTP_SOCKET_TCP
>> and the ipv4/ip_sockglue.c code is only masking out ECN for SOCK_STREAM
>> types.
>>
>> Is this per design, or should the ip_sockglue.c mask out ECN for
>> SCTP_SOCKET_TCP
>> types as well?
>>
>> Thanks,
>> Ben
>>
>
>  From the ip_glue perspective, you would see either SOCK_STREAM or
> SOCK_SEQPACKET.
>
> So you are trying to set tos bits on a SEQPACKET socket, ip_sockglue()
> wouldn't try preserver current ECN bits as it does for STREAM sockets.

Actually, I am just reading the TOS, and should never be setting it
at all in this particular test case.  TCP connections return 0x0 in
this case, but SCTP returns 0x2.

It's a small issue, but it screwed up some sub-standard code in
my application, so that is why I noticed it.

It *could* be that my app is somehow to blame.  I'll poke around
in the kernel with printk when I get a chance.

Thanks,
Ben

>
> -vlad
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
