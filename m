From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v5 01/10] devlink: Add permanent config
 parameter get/set operations
Date: Mon, 30 Oct 2017 15:12:13 -0700
Message-ID: <20171030151213.431dfbff@cakuba.netronome.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
        <1509374776-45869-2-git-send-email-steven.lin1@broadcom.com>
        <20171030170301.GE4115@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com, yuvalm@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:13833 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752786AbdJ3WMW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 18:12:22 -0400
In-Reply-To: <20171030170301.GE4115@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Oct 2017 18:03:01 +0100, Jiri Pirko wrote:
> >+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
> >+	/* Update restart reqd - if any param needs restart, should be set */
> >+	if (need_restart) {  
> 
> You should propagate this out so the caller would fill it to the
> message. This is a global thing, not per-param, shoult not be nested.

Right, I think Jiri has already asked for this but I feel like we
should provide the ability to query running/pending configurations
independently.  I don't see it in this patch set?

I'm not sure what the status of the reconfig trigger patches for mlxsw
is, but we actually may need 3 config sets:
 - current/runtime configurable, 
 - requiring soft reset of the device/driver reinit;
 - requiring hard reset/set on boot.

Secondly, IMHO calling set/get parameters "permanent" is a bit
backwards.  One device may not be able to change max VF counts or MSIX
allocation without full reinit of PCIe blocks, but for others soft
reset is more than enough.  Port splitting is another example.  For 
NICs port splitting at runtime is usually not a priority in HW/FW
development, so some form of reset is generally required, while
switches can split a port at runtime.  IOW we should define parameters
without assigning them to config sets in the ABI itself.  And also we
should make it in a way which will allow existing parameters to be
reused in permanent/sort reset required/runtime modes.

Does that make sense?
