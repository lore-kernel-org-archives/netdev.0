From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for mobility
 header.
Date: Wed, 27 Dec 2006 13:57:23 +0900
Message-ID: <4591FD33.3070205@linux-ipv6.org>
References: <11653130071739-git-send-email-nakam@linux-ipv6.org>	<20061205.200242.01826773.yoshfuji@linux-ipv6.org>	<20061210.225055.45514229.davem@davemloft.net> <20061227.111429.51867516.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:34365 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932914AbWL0F0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Dec 2006 00:26:19 -0500
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061227.111429.51867516.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? wrote:
> If it is okay to defer the checksumming after checking the next header
> protocol, we can omit the checksumming in mip6_mh_filter(), and
> leave it to rawv6_rcv() and rawv6_recvmsg().
> 
> 
> Anyway, we have 4 options.
> 
> 1. IPV6_CHECKSUM default for IPPROTO_MH == 4
>    omit checksumming in mip6_mh_filter()
> 2. IPV6_CHECKSUM default for IPPROTO_MH == -1
>    omit checksumming in mip6_mh_filter()
> 3. IPV6_CHECKSUM for IPPROTO_MH == 4
>    always perform checksumming in mip6_mh_filter()
> 4. IPV6_CHECKSUM default for IPPROTO_MH == -1
>    always perform checksumming in mip6_mh_filter()
> 
> Current behavior is 4, but it is not appropriate.
> I guess 1 is the way to go.

I would like to have 1, too.

> Another question may arise; is it okay to change the default if the
> raw socket for Mobility Header is NOT for user-space daemon? or,

For such application (if any), it has used setsockopt = 4 or hasn't used it
for inbound checksum. Those code should work with the kernel change then I
can not find any issue here. Do you have anything else to be discussed?

> is it okay to have two different default value depending on CONFIG_IPV6_MIP6?
> If we take these question seriously, we should take 2.

We have a solution here, to remove "ifdef CONFIG_IPV6_MIP6" from
rawv6_init_sk() to have the same default value = 4 for IPPROTO_MH
regardless user config.

BTW ICMPv6 default is on and offset = 2. It is better idea for me
to have the similar design for both MH and ICMPv6 as raw socket stuff
than you pointed.

Regards,

-- 
Masahide NAKAMURA
