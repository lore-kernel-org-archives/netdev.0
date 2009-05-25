From: Matthias Schwarzott <zzam@gentoo.org>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d" as interface name
Date: Mon, 25 May 2009 10:33:08 +0200
Message-ID: <200905251033.09272.zzam@gentoo.org>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de> <alpine.DEB.2.01.0905232309400.7424@bogon> <tkrat.6c3758bf0544a790@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Christian Kujau <lists@nerdbynature.de>,
	linux-kernel@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-hotplug@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <tkrat.6c3758bf0544a790@s5r6.in-berlin.de>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sonntag, 24. Mai 2009, Stefan Richter wrote:
> Christian Kujau wrote at LKML:
> > If the patch will be accepted at all and it's not too late to ask: I'd
> > vote for fw%d as well, "firefire" just looks too long, for me at least.
>
> I think I'll leave the driver as it is.
> As I just noticed, we would lose interface renaming by udev.
> From udev/extras/rule_generator/75-persistent-net-generator.rules:
>
>   # device name whitelist
>   KERNEL!="eth*|ath*|wlan*[0-9]|msh*|ra*|sta*|ctc*|lcs*|hsi*",
> GOTO="persistent_net_generator_end"
>
> Besides, if we can we should avoid fw%d because this will clash with
> udev rules which match KERNEL=="fw*", as in
> udev/rules/redhat/40-redhat.rules.

I suggest a subsystem match here, or generally some
SUBSYSTEM!="net", GOTO="end_of_file"
around almost all rule files that should not match on network interfaces, as 
users can rename them to almost all crazy names.

@Kay: Perhaps it could simplify some rulesets to have a special jump target or 
option to skip entiere rules files.

Regards
Matthias
