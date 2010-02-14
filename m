From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm : fix /sys/devices/virtual/atm/X/carrier(ATM_PHY_SIG_UNKNOWN)
Date: Sun, 14 Feb 2010 16:34:40 -0500
Message-ID: <201002142134.o1ELYehH019725@thirdoffive.cmf.nrl.navy.mil>
References: <20100214175136.GA15891@frolo.macqel>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:59470 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414Ab0BNVev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 16:34:51 -0500
In-reply-to: <20100214175136.GA15891@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20100214175136.GA15891@frolo.macqel>,Philippe De Muyter writes:
>OK for me.  I would agree with
>
>	carrier = 0 when signal == ATM_PHY_SIG_UNKNOWN,
>
>but currently we have
>
>	carrier = 1 when signal == ATM_PHY_SIG_UNKNOWN

not quite what i said (or perhaps i didnt clearly convey my intent).
ATM_PHY_SIG_UNKNOWN is set during the driver create/initialize.
unfortunately, some drivers never bothers to set signal so it winds up
always being unknown.  however, for those drivers, we cant assume the
carrier is 0, or nothing will happen if someone is watching for the
carrier to be 1.

so, all drivers, if they arent going to support setting signal should
just assign it to 1.  i would sort of prefer that ATM_PHY_SIG_UNKNOWN
simply didnt exist.  as i said before there is carrier or there is
not.  if the driver doesnt support checking/knowing the carrier status
it should simply say 'yes i have carrier'.

i will see if i cant workup a little patch for this today.
