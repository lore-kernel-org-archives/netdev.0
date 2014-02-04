From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] dp83640: Support a configurable number of periodic
 outputs
Date: Tue, 4 Feb 2014 10:29:39 +0100
Message-ID: <20140204092939.GA9862@netboy>
References: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:50599 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbaBDJ34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 04:29:56 -0500
Received: by mail-ee0-f42.google.com with SMTP id b15so2313829eek.29
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 01:29:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 04, 2014 at 09:52:22AM +0100, Stefan S=F8rensen wrote:
> The driver is currently limited to a single periodic output.
> This patch makes the number of peridodic output dynamic by
> dropping the gpio_tab module parameter and adding cal_gpio,
> perout_gpio_tab and extts_gpio_tabs parameters.

=2E..

>  module_param(chosen_phy, int, 0444);
> -module_param_array(gpio_tab, ushort, NULL, 0444);
> +module_param(cal_gpio, int, 0444);
> +module_param_array(perout_gpio_tab, int, &n_perout, 0444);
> +module_param_array(extts_gpio_tab, int, &n_extts, 0444);
> =20
>  MODULE_PARM_DESC(chosen_phy, \
>  	"The address of the PHY to use for the ancillary clock features");
> -MODULE_PARM_DESC(gpio_tab, \
> -	"Which GPIO line to use for which purpose: cal,perout,extts1,...,ex=
tts6");
> +MODULE_PARM_DESC(cal_gpio, "Which GPIO line to use for calibration")=
;
> +MODULE_PARM_DESC(perout_gpio_tab, "Which GPIO lines to use for perio=
dic output");
> +MODULE_PARM_DESC(extts_gpio_tab, "Which GPIO lines to use for extern=
al timestamping");

Modules parameters are surely easiest (for the developer), but perhaps
the time has come for the "right way."

Currently there is no interface for configuring the GPIOs used by PHC
devices, and last year I was going to add the GPIOs to the igb
driver. The conclusion of the discussion was that module parameters
are bad for this, but ethtool is good.

  http://www.spinics.net/lists/netdev/msg237692.html

[ I did not follow through to come up with an ethtool way of configurin=
g
  the igb pins. ]

Even though it is more work, I think the way forward is to invent a
way to let the user configure this kind of thing via ethtool. Would
you care to take a stab at this?

Thanks,
Richard
