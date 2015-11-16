From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: What's the expected path to recover from a PHY_HALTED transition?
Date: Mon, 16 Nov 2015 11:48:46 -0800
Message-ID: <564A331E.6090603@gmail.com>
References: <CAJ-Vmon_s0o7G84CBOb_V5Y-D-3TMNDq7AOhr9fdiOmxYaFBZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Adrian Chadd <adrian@freebsd.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34398 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbKPTto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:49:44 -0500
Received: by pacfl14 with SMTP id fl14so25938659pac.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 11:49:44 -0800 (PST)
In-Reply-To: <CAJ-Vmon_s0o7G84CBOb_V5Y-D-3TMNDq7AOhr9fdiOmxYaFBZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/11/15 11:29, Adrian Chadd wrote:
> hi,
> 
> I'm debugging an issue on the Broadcom parts (using unimac-mdio.c as
> the mdio bus) where i occasionally see MDIO bus read failures, which
> causes phy.c to transition the PHY to PHY_HALTED. It stays in this
> state until the link is bounced.

There is a known problem with some Broadcom PHYs where the first MDIO
read may fail, and this can actually show up randomly in time, not just
the first read and that caused the PHY library to enter PHY_HALTED.
Which part are you seeing this? unimac-mdio.c has a reset hook just for
that cases.

> 
> So, what's the expectation to handle this and recover from it? is
> there some userland piece monitoring things that I'm missing?

There is not much you can do typically, but ignore or retry the read, or
workaround it if you can, like what bcm7xxx.c does.
-- 
Florian
