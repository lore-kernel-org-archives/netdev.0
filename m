From: Santwona.Behera@Sun.COM
Subject: Re: [PATCH 1/3] [ethtool] Add support for RX packet classification in
 a network device
Date: Mon, 09 Feb 2009 19:17:09 -0800
Message-ID: <4990F1B5.2070002@Sun.COM>
References: <4990B855.30905@Sun.COM>
 <20090209.180306.156744968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	jeff@garzik.org, Matheos.Worku@Sun.COM, Mehdi.Bonyadi@Sun.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:37425 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbZBJDRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 22:17:20 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1A3HD2I028282
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 19:17:16 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KET00100Y3OPP00@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Mon,
 09 Feb 2009 19:17:13 -0800 (PST)
In-reply-to: <20090209.180306.156744968.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/ 9/09 06:03 PM, David Miller wrote:
> From: Santwona.Behera@Sun.COM
> Date: Mon, 09 Feb 2009 15:12:21 -0800
> 
>> +struct ethtool_tcpip4_spec {
>> +	__u32	ip4src;
>> +	__u32	ip4dst;
>> +	__u16	psrc;
>> +	__u16	pdst;
>> +	__u8    tos;
>> +};
> 
> The IP addresses and ports in these new interfaces, are
> they to be specified in network or cpu byte order?

The interfaces assumes that they are to be specified in network order. I 
will add a comment to mention that.

Looking back at my ethtool(8) patch, I have a bug in the code where I do 
not do this translation for the ports and spi (I got it right for the IP 
addresses). I will fix this and repost all the patches.

Thanks for raising this.

--santwona

> 
> That's usually the first thing a person will wonder when
> trying to use to implement support for these interfaces.
> 
> My guess is that the specification is cpu endianness,
> however note that this flies in the face with how this
> is handled in pretty much every other networking interface
> in the kernel.  The standard is to use network endianness
> when passing ports and IP addressing information into the
> kernel.
> 
> I wouldn't reject this patch series just for this reason,
> in fact I'm ready to apply this stuff, but just thought I'd
> mention it just in case you hadn't considered the issue
> yourself.
