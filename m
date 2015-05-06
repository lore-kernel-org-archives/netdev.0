From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 03/21] switchdev: introduce get/set attrs ops
Date: Wed, 6 May 2015 05:11:54 +0200
Message-ID: <20150506031154.GA1992@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33921 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbbEFDL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 23:11:58 -0400
Received: by wicmx19 with SMTP id mx19so114955876wic.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 20:11:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847297-15728-4-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:34:39PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Add two new swdev ops for get/set switch port attributes.  Most swdev
>interactions on a port are gets or sets on port attributes, so rather than
>adding ops for each attribute, let's define clean get/set ops for all
>attributes, and then we can have clear, consistent rules on how attributes
>propagate on stacked devs.
>
>Add the basic algorithms for get/set attr ops.  Use the same recusive algo
>to walk lower devs we've used for STP updates, for example.  For get,
>compare attr value for each lower dev and only return success if attr
>values match across all lower devs.  For sets, set the same attr value for
>all lower devs.  We'll use a two-phase prepare-commit transaction model for
>sets.  In the first phase, the driver(s) are asked if attr set is OK.  If
>all OK, the commit attr set in second phase.  A driver would NACK the
>prepare phase if it can't set the attr due to lack of resources or support,
>within it's control.  RTNL lock must be held across both phases because
>we'll recurse all lower devs first in prepare phase, and then recurse all
>lower devs again in commit phase.  If any lower dev fails the prepare
>phase, we need to abort the transaction for all lower devs.
>
>If lower dev recusion isn't desired, allow a flag SWITCHDEV_F_NO_RECURSE to
>indicate get/set only work on port (lowest) device.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
