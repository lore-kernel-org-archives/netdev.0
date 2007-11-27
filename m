From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: 2.6.23-mm1 tg3 wake-on-lan oddity...
Date: Tue, 27 Nov 2007 13:34:57 -0800
Message-ID: <1196199297.7323.10.camel@dell>
References: <24400.1196156118@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "netdev" <netdev@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1806 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756430AbXK0Uoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 15:44:34 -0500
In-Reply-To: <24400.1196156118@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-11-27 at 01:35 -0800, Valdis.Kletnieks@vt.edu wrote:

> 
> Issue:
> 
> I (for unrelated reasons) run powertop, and it suggests I conserve power
> by doing 'ethtool -s eth0 wol d'.  I look at it, and think that it's daft,
> because (a) the Dell factory default is WOL disabled and (b) if it wasn't
> the default, I'd have *set* it to disabled, and (c) I even went back and
> rebooted and checked the BIOS setting - disabled. Nonetheless:
> 
> # ethtool eth0 | grep Wake
>         Supports Wake-on: g
>         Wake-on: g
> 
> Is this expected behavior?

What's happening is that there are 2 WoL settings: one in the BIOS and
one in the NIC's NVRAM.  For WoL to work, I think both settings have to
be enabled.  Apparently in this case, when you turn off WoL in the BIOS,
the NVRAM's WoL setting is unchanged, and will be seen by tg3 as
enabled.

Ideally, the BIOS should modify the NVRAM's setting when it is changed.
We will talk to Dell to get their opinion on this as this is very
confusing to the user.

Thanks.

