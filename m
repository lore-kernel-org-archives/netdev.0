From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v7 05/24] rocker: support prepare-commit
 transaction model
Date: Sun, 10 May 2015 21:20:19 +0200
Message-ID: <20150510192019.GA2022@nanopsycho>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
 <1431276489-64199-6-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34990 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbbEJTUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 15:20:25 -0400
Received: by wgbhc8 with SMTP id hc8so10695202wgb.2
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 12:20:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431276489-64199-6-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 10, 2015 at 06:47:50PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>For rocker, support prepare-commit transaction model for setting attributes
>(and for adding objects).  This requires rocker to preallocate memory
>needed for the commit up front in the prepare phase.  Since rtnl_lock is
>held between prepare-commit, store the allocated memory on a queue hanging
>off of the rocker_port.  Also, in prepare phase, do everything right up to
>calling into HW.  The same code paths are tranversed in the driver for both
>prepare and commit phases.  In some cases, any state modified in the
>prepare phase must be reverted before returning so the commit phase makes
>the same decisions.
>
>As a consequence of holding rtnl_lock in process context for all attr sets
>(and obj adds), all memory is GFP_KERNEL allocated and we don't need to
>busy spin waiting for the device to complete the command.  So the bulk of
>this patch is simplifying the memory allocations to only use GFP_KERNEL and
>to remove the nowait flag and busy spin loop.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
