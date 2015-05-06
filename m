From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v5 05/21] switchdev: convert STP update to
 switchdev attr set
Date: Tue, 5 May 2015 22:32:09 -0700
Message-ID: <CAE4R7bBHGdMsmNdBS7ifC9CW4traWo71NbUM92mxeJzF47f-uQ@mail.gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
	<1430847297-15728-6-git-send-email-sfeldma@gmail.com>
	<20150506032217.GC1992@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33539 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbbEFFcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 01:32:10 -0400
Received: by qkx62 with SMTP id 62so121356227qkx.0
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 22:32:10 -0700 (PDT)
In-Reply-To: <20150506032217.GC1992@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 5, 2015 at 8:22 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, May 05, 2015 at 07:34:41PM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>STP update is just a settable port attribute, so convert
>>switchdev_port_stp_update to an attr set.
>>
>>For rocker, support prepare-commit transaction model for setting STP state.
>>This requires rocker to preallocate memory needed for the commit up front
>>in the prepare phase.  Since rtnl_lock is held between prepare-commit,
>>store the allocated memory on a queue hanging off of the rocker_port.
>>Also, in prepare phase, do everything right up to calling into HW.  The
>>same code paths are tranversed in the driver for both prepare and commit
>>phases.  In some cases, any state modified in the prepare phase must be
>>reverted before returning so the commit phase makes the same decisions.
>>
>>For rocker, as a consequence of holding rtnl_lock in process context for
>>all attr sets (and obj adds), all memory is GFP_KERNEL allocated and we
>>don't need to busy spin waiting for the device to complete the command.  So
>>the bulk of this patch is simplifying the memory allocations to only use
>>GFP_KERNEL and to remove the nowait flag and busy spin loop.
>>
>>For DSA, the prepare phase is skipped and STP updates are only done in the
>>commit phase.  This is because currently the DSA drivers don't need to
>>allocate any memory for STP updates and the STP update will not fail to HW
>>(unless something horrible goes wrong on the MDIO bus, in which case the
>>prepare phase wouldn't have been able to predict anyway).
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> Hmm. This patch looks like a squash of two independent patches. It would
> be better to push alloc change and stp update change as separate
> patches.

I'll split it in v6.
