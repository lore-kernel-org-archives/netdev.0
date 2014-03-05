From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCHv2 3/5] net: rfkill: gpio: remove gpio names
Date: Wed, 5 Mar 2014 09:43:16 +0800
Message-ID: <CACRpkdZF4-rWs1WkOp3t0x77fgSCE71E=wdrxiDuGZ8eBu_p_Q@mail.gmail.com>
References: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com>
	<1393330950-7283-4-git-send-email-heikki.krogerus@linux.intel.com>
	<530D218E.9010007@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Chen-Yu Tsai <wens@csie.org>,
	Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>, Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:54799 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756736AbaCEBnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 20:43:18 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so399855oag.0
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 17:43:17 -0800 (PST)
In-Reply-To: <530D218E.9010007@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 7:04 AM, Stephen Warren <swarren@wwwdotorg.org> wrote:

>> -     gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
>> +     gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);
>
> I think the correct fix here is to look up the GPIO by name rather than
> by index, but simply hard-code the name rather than generating it with
> sprintf(). Index lookups are hard to expand compatibly, but named-based
> lookups scale much better.
>
> In other words, I rather specifically disagree with using a plain
> "gpios" property in any future DT binding, but would strongly prefer
> e.g. reset-gpios/shutdown-gpios or gpios/gpio-names.

If I understand the situation correctly it's like ACPI does not have named
GPIOs so keeping specifying this in DT GPIO bindings is counter-productive
to the work of abstracting the access to GPIO handlers so that drivers
need not know whether ACPI or DT is used for describing the hardware.

We could do worse. Like putting the GPIOs in a differently indexed order
in DT vs ACPI.

I have no strong opinion really, I just see that people doing DT and ACPI
HW descriptions need to cooperate if they want to share infrastructure
or we have to give up that pipe dream and let each HW description
method have its own unique probe()-runpath. Which would be the result
in this driver if we persist on using named GPIOs.

Yours,
Linus Walleij
