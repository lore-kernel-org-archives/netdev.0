From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv6: default route for link local address is not added
 while assigning a address
Date: Wed, 29 Jan 2014 11:38:47 +0100
Message-ID: <52E8DA37.7010208@6wind.com>
References: <52E8A2AA.3090507@linux.vnet.ibm.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sohny Thomas <sthomas@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	kumuda <kumuda@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:58290 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaA2Kiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 05:38:52 -0500
Received: by mail-ee0-f47.google.com with SMTP id d49so789545eek.6
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 02:38:49 -0800 (PST)
In-Reply-To: <52E8A2AA.3090507@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/01/2014 07:41, Sohny Thomas a =E9crit :
> Resending this on netdev mailing list:
> Default route for link local address is configured automatically if
> NETWORKING_IPV6=3Dyes is in ifcfg-eth*.
> When the route table for the interface is flushed and a new address i=
s added to
> the same device with out removing linklocal addr, default route for l=
ink local
> address has to added by default.
>
> I have found the issue to be caused by this checkin
>
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit=
/net/ipv6?id=3D62b54dd91567686a1cb118f76a72d5f4764a86dd
>
>
> According to this change :
> He removes adding a link local route if any other address is added , =
applicable
> across all interfaces though there's mentioned only lo interface
> So below patch fixes for other devices
>
> Signed-off-by: Sohny THomas <sohthoma@linux.vnet.ibm.com>
Your email client has corrupted the patch, it cannot be applied.
Please read Documentation/email-clients.txt

About the patch, I still think that the flush is too agressive. Link lo=
cal
routes are marked as 'proto kernel', removing them without the link loc=
al
address is wrong.

With this patch, you will add a link local route even if you don't have=
 a link
local address.
