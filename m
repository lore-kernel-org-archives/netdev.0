From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 16:06:58 -0800
Message-ID: <56C3B9A2.6040401@gmail.com>
References: <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
 <20160216221536.GB6033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36513 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933243AbcBQAIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 19:08:10 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so323548pab.3
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 16:08:10 -0800 (PST)
In-Reply-To: <20160216221536.GB6033@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/02/16 14:15, Andrew Lunn wrote:
>> I just spoke with my manager, and we would like to change the target
>> device from LAN9352 to LAN9250. The LAN9250 is the same as the
>> LAN9352 but without the switch. It has one mac and one phy.
> 
> It is not so easy to get an overview from the website, but it looks
> like:
> 
> LAN9250 - one port MAC/PHY
> LAN9352 - 10/100 2-Port Managed Ethernet Switch
> LAN9353 - 10/100 3-Port Managed Ethernet with Dual RMII or Single MII/RMII/Turbo MII
> LAN9354 - 10/100 3-Port Managed Ethernet Switch with Single RMII
> LAN9355 - 10/100 3-Port Managed Ethernet Switch with Dual MII/RMII/Turbo MII
> 
> So i get the feeling this product line is for switches, and the
> LAN9250 is an oddball in the series.
> 
> You are already 1/2 way to a DSA driver, since you have a MAC
> driver. So i agree with David, do it right and add a simple DSA
> driver.

I second that, and in fact, implemeting a DSA driver will get you the
per-port ethtool control knobs that you are after.

Even if your driver does not support tagging (you can set
DSA_PROTO_TAG_NONE to not requiring tagging), you still get all the
other DSA perks: per-port network devices, ethtool statistics, PHY
management, etc.

The in-kernel documentation in Documentation/networking/dsa/dsa.txt is
reasonably up to date
-- 
Florian
