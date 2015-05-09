From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 14/23] bridge: restore br_setlink back to
 original
Date: Sat, 9 May 2015 21:00:32 +0200
Message-ID: <20150509190031.GG2290@nanopsycho>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
 <1431193225-807-15-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35771 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbEITAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 15:00:38 -0400
Received: by widdi4 with SMTP id di4so63924962wid.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 12:00:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431193225-807-15-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 09, 2015 at 07:40:16PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Restore br_setlink back to original and don't call into SELF port driver.
>rtnetlink.c:bridge_setlink() already does a call into port driver for SELF.
>
>bridge set link cmd defaults to MASTER.  From man page for bridge link set
>cmd:
>
>       self   link setting is configured on specified physical device
>
>       master link setting is configured on the software bridge (default)
>
>The link setting has two values: the device-side value and the software
>bridge-side value.  These are independent and settable using the bridge
>link set cmd by specifying some combination of [master] | [self].
>Futhermore, the device-side and bridge-side settings have their own initial
>value, viewable from bridge -d link show cmd.
>
>Restoring br_setlink back to original makes rocker (the only in-kernel user
>of SELF link settings) work as first implement: two-sided values.
>
>It's true that when both MASTER and SELF are specified from the command,
>two netlink notifications are generated, one for each side of the settings.
>The user-space app can distiquish between the two notifications by
>observing the MASTER or SELF flag.

This is revert of:

commit 68e331c785b85b78f4155e2ab6f90e976b609dc1
Author: Roopa Prabhu <roopa@cumulusnetworks.com>
Date:   Thu Jan 29 22:40:14 2015 -0800

    bridge: offload bridge port attributes to switch asic if feature flag set

Noting that because I want to make sure everybody is ok with new
behaviour. I tend to like it more.

Maybe you can include del part into this patch and mark is clearly as a
revert.

anyway:
Acked-by: Jiri Pirko <jiri@resnulli.us>
