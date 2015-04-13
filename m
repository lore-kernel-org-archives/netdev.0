From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 03/24] switchdev: convert STP update to swdev
 attr set
Date: Mon, 13 Apr 2015 12:22:27 -0700
Message-ID: <552C1773.3030907@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com> <1428905838-14920-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36369 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbbDMTX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 15:23:29 -0400
Received: by pdea3 with SMTP id a3so117057903pde.3
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 12:23:29 -0700 (PDT)
In-Reply-To: <1428905838-14920-4-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/15 23:16, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> STP update is just a writable port attribute, so convert swdev_port_stp_update
> to an attr set.
> 
> For rocker, support prepare-commit transaction model for setting STP state.
> This requires rocker to preallocate memory needed for the commit up front in
> the prepare phase.  Since rtnl_lock is held between prepare-commit, store the
> allocated memory on a queue hanging off of the rocker_port.  Also, in prepare
> phase, do everything right up to calling into HW.  The same code paths are
> tranversed in the driver for both prepare and commit phases.  In some cases,
> any state modified in the prepare phase must be reverted before returning
> so the commit phase makes the same decisions.

I now better understand the reason for introducing both the object and
transactional model, but that is really a dramatic change in the API
complexity now, and unfortunately this is reflected in the drivers using
it...

Can we try to classify switches by their underlying control/transport
bus, essentially sleeping vs. non-sleeping I/O operations and provide a
good enough abstraction from there which avoids drivers like rocker to
have to maintain a list of transactions?
-- 
Florian
