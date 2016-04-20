From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Wed, 20 Apr 2016 11:03:11 -0700
Message-ID: <5717C45F.30205@gmail.com>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: Amr Bekhit <amrbekhit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35799 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbcDTSFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 14:05:22 -0400
Received: by mail-pf0-f173.google.com with SMTP id n1so20694678pfn.2
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 11:05:22 -0700 (PDT)
In-Reply-To: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 20/04/16 08:21, Amr Bekhit wrote:
> Hello,
> 
> I'm using an embedded Linux board based on an AT91SAM9X25 that uses the
> Davicom DM9162IEP PHY chip. I'm struggling to get packets out on the
> wire and I'm suspecting that I might have an issue between the AT91 MAC
> and the PHY chip. I've looked through the kernel config options and the
> kernel already has compiled-in support for the Davicom PHYs, however I
> noticed that according to the help text, only the dm9161e and dm9131
> chips are supported, which may indicate why my ethernet isn't working. I
> was wondering whether the DM9162 is backwards compatible with the
> existing driver? I'm currently using the mainline kernel 4.3. (p.s. I
> know the hardware works fine since I have no problem transferring files
> using tftp via u-boot).

Well, u-boot is a very simplistic networking stack, there could be tons
of issues that get under the radar because it cannot report them
properly, but let's assume it works so you have something to compare
against.

The DM9162 should be very similar to the DM9161, so the first thing
might be trying to add the PHY ID (32-bits OUI) to the matching table in
drivers/net/phy/davicom.c, and make it configure the PHY through
dm9161_config_init() since that looks at the PHY interface (MII, RMII
etc.) and does a bit of configuration here.

Right now, chances are that you are running with the Generic PHY driver
which has no clue about Davicom specific programming (if any). There
could also be board-level fixups required (adjusting trace lengths, if
you are using a RGMII interface for instance), etc.
-- 
Florian
