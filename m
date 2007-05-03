From: Jelle Foks <jelle@foks.8m.com>
Subject: Re: r8169.c broke for me from 2.6.20.4 to 2.6.21
Date: Thu, 03 May 2007 00:10:50 -0400
Message-ID: <463960CA.1080902@foks.8m.com>
References: <20070502223136.GA19750@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.tampabay.rr.com ([65.32.5.133]:39144 "EHLO
	ms-smtp-03.tampabay.rr.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767364AbXECEKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 00:10:53 -0400
Received: from silicon.elements (115.218.8.67.cfl.res.rr.com [67.8.218.115])
	by ms-smtp-03.tampabay.rr.com (8.13.6/8.13.6) with ESMTP id l434ApEs026069
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 00:10:52 -0400 (EDT)
Received: from [10.4.0.1] (firewall.elements.elements [10.4.0.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by silicon.elements (Postfix) with ESMTP id 2D8244C9B91
	for <netdev@vger.kernel.org>; Thu,  3 May 2007 00:10:51 -0400 (EDT)
In-Reply-To: <20070502223136.GA19750@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please don't trim the Cc:. The bugs must be processed publicly to feed
> the oracle.
Ok.
>
> Jelle Foks <jelle@foks.8m.com> :
>> Francois Romieu wrote:
> [...]
>>> Can you:
>>> - send the output of a 'lspci -vvx'
>>>   
>> See attached lspci.txt, the ethernet card chip, obviously, at 00:0b.0
>
> Plain old 8169. Ok.
>
> [...]
>>> - send the output of mii-tool including hex dump of the registers with
>>>   2.6.20.4 and 2.6.21
>>>   
>> $ sudo /sbin/mii-tool -v -v
>> Using SIOCGMIIPHY=0x8947
>> eth1: 10 Mbit, half duplex, link ok
>>   registers for MII PHY 32:
>>     0000 794d 001c c910 0de1 0020 0004 2001
>>     0000 0300 0000 1000 1007 f880 0000 3000
>>     0060 0c00 0000 0000 0060 0000 009a 0108
>>     2740 0088 0000 8000 8400 0000 0000 4830
>>   product info: vendor 00:07:32, model 17 rev 0
>>   basic mode:   10 Mbit, half duplex
>>   basic status: link ok
>>   capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
>>   advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
>>   link partner: 10baseT-HD
>
> 1. Can you send the output of mii-tool on the other kernel too ?
>From the 2.6.21 pristine, when the link stays down:

Using SIOCGMIIPHY=0x8947
eth1: no link
  registers for MII PHY 32:
    1000 7949 001c c910 0de1 0000 0004 2001
    0000 0300 0000 1000 1007 f880 0000 3000
    0060 4000 0000 0040 0060 0000 0098 0108
    2740 0088 0000 8000 8400 0000 0000 0840
  product info: vendor 00:07:32, model 17 rev 0
  basic mode:   autonegotiation enabled
  basic status: no link
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

>
> 2. Any change if you use the patch below on 2.6.21 ? No need to wait for
>    minutes if it does not perform better btw.
No changes, link stays down, just like with 2.6.21 pristine.

Hope this helps,

Jelle.

>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 5b42176..d2082ef 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -525,7 +525,8 @@ static unsigned int rtl8169_tbi_link_ok(void __iomem *ioaddr)
>  
>  static unsigned int rtl8169_xmii_link_ok(void __iomem *ioaddr)
>  {
> -	return RTL_R8(PHYstatus) & LinkStatus;
> +	return (RTL_R8(PHYstatus) & LinkStatus) ? 1 :
> +		(RTL_R8(PHYstatus) & LinkStatus);
>  }
>  
>  static void rtl8169_tbi_reset_enable(void __iomem *ioaddr)
>

