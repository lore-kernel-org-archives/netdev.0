From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Commit-8b63ec18 breaks setting PHY pad-skew settings
Date: Mon, 21 Dec 2015 11:50:32 -0800
Message-ID: <56785808.6050804@gmail.com>
References: <FC629F1A536C6F42B960B5E32E20BD356A967AF0@exc2.buero.ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	"grant.likely@secretlab.ca" <grant.likely@secretlab.ca>,
	"davem@davemloft.net" <davem@davemloft.net>,
	netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: Roosen Henri <Henri.Roosen@ginzinger.com>,
	"david.daney@cavium.com" <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36474 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbbLUTuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 14:50:52 -0500
Received: by mail-pa0-f53.google.com with SMTP id q3so83830445pav.3
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 11:50:51 -0800 (PST)
In-Reply-To: <FC629F1A536C6F42B960B5E32E20BD356A967AF0@exc2.buero.ginzinger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/12/15 02:40, Roosen Henri wrote:
> Hi David,
> 
> Unfortunately Linux kernel commit-8b63ec1837fa4c1ea604b278d201454eb3b85066 breaks setting pad-skew settings for Micrel PHY's.
> 
> Please see Documentation/devicetree/bindings/net/micrel-ksz90x1.txt: at the examples, it proposes to do PHY pad skew settings at the Ethernet device for autodetected PHY's.
> 
> Multiple boards are using this at the devicetree files: see imx6qdl-nitrogen6x.dtsi, imx6qdl-sabrelite.dtsi, socfpga_arria5_socdk.dts, socfpga_cyclone5_socdk.dts and socfpga_cyclone5_sockit.dts. But of course there might be more users depending on this than the ones which have an in-kernel dts file.
> 
> The micrel.c file searches for the parent of its OpenFirmware node for the skew settings: see ksz9031_config_init(): of_node = dev->parent->of_node; I don't think that was a clean implementation to start with.. But for sure it's incompatible with commit-8b63ec18, because the node of the Ethernet device which has the settings is not found anymore.
> 
> I'm not sure who to put on the copy list to discuss a proper solution, so feel free to get these persons and lists in the loop.

Usually, the best thing is to reply on the mailing-list directive, so
more people can jump in.

This particular issue is fixed with the following commit:

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=651df2183543bc92f5dbcf99cd9e236ead0bc4c5
-- 
Florian
