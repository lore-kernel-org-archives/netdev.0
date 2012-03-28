From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v4] Ethernet driver for the WIZnet W5300 chip
Date: Wed, 28 Mar 2012 11:52:43 +0600
Message-ID: <4F72A72B.5020609@permonline.ru>
References: <1332149037-12025-1-git-send-email-msink@permonline.ru><1332752876-1650-1-git-send-email-msink@permonline.ru> <20120327.223545.1996930432677091672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.ccl.ru ([195.222.140.73]:50657 "EHLO mail4.ccl.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195Ab2C1Fw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 01:52:56 -0400
In-Reply-To: <20120327.223545.1996930432677091672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

28.03.2012 8:35, David Miller wrote:

>> +/*
>> + * Frame size is hardwired to 1514 bytes (including header),
>> + *  =>  MTU for 802.1Q frames must be set to 1500-4 = 1496
>> + */
>> +#define W5300_HARD_MTU		1500
>
> I've told you that you must set the VLAN challenged feature flag
> (NETIF_F_VLAN_CHALLENGED) for devices which have this restriction.
>
> Just set that, and remove this comment, since the feature bit setting
> documents this restriction fully and perfectly.

 From Documentation/netdev-features.txt:

 >NETIF_F_VLAN_CHALLENGED should be set for devices which can't cope 
with VLAN
 >headers. Some drivers set this because the cards can't handle the 
bigger MTU.
 >[FIXME: Those cases could be fixed in VLAN code by allowing only 
reduced-MTU
 >VLANs. This may be not useful, though.]

My case is exactly what is here in FIXME comment - yes, this chip cannot 
handle full size MTU for VLANs, and TCP/IP traffic don't work well over 
this VLAN. But we actually use it for traffic where frame size is known 
to be less than 1500 - TDMoE to Asterisk in our case - and it works 
perfectly.
So as ideal we'll like to disable TCP/IP over this sort of VLANs, but 
still enable TDMoE traffic. If it is possible.

But if you want - ok, I'll disable VLAN support entirely for this chip 
in mainline version.

(Now working on similar driver for W5100 chip, hopefully will post both 
soon.)

-- 
Mike
