From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 01/10] devlink: Add permanent config
 parameter get/set operations
Date: Tue, 31 Oct 2017 08:17:30 +0100
Message-ID: <20171031071730.GB1972@nanopsycho.orion>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
 <1509374776-45869-2-git-send-email-steven.lin1@broadcom.com>
 <20171030170301.GE4115@nanopsycho.orion>
 <20171030151213.431dfbff@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Lin <steven.lin1@broadcom.com>, netdev@vger.kernel.org,
        jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:51459 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751564AbdJaHRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 03:17:32 -0400
Received: by mail-wm0-f52.google.com with SMTP id b9so20918298wmh.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 00:17:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171030151213.431dfbff@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 30, 2017 at 11:12:13PM CET, kubakici@wp.pl wrote:
>On Mon, 30 Oct 2017 18:03:01 +0100, Jiri Pirko wrote:
>> >+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
>> >+	/* Update restart reqd - if any param needs restart, should be set */
>> >+	if (need_restart) {  
>> 
>> You should propagate this out so the caller would fill it to the
>> message. This is a global thing, not per-param, shoult not be nested.
>
>Right, I think Jiri has already asked for this but I feel like we
>should provide the ability to query running/pending configurations
>independently.  I don't see it in this patch set?

I don't see it either :/


>
>I'm not sure what the status of the reconfig trigger patches for mlxsw
>is, but we actually may need 3 config sets:
> - current/runtime configurable, 
> - requiring soft reset of the device/driver reinit;
> - requiring hard reset/set on boot.
>
>Secondly, IMHO calling set/get parameters "permanent" is a bit
>backwards.  One device may not be able to change max VF counts or MSIX
>allocation without full reinit of PCIe blocks, but for others soft
>reset is more than enough.  Port splitting is another example.  For 
>NICs port splitting at runtime is usually not a priority in HW/FW
>development, so some form of reset is generally required, while
>switches can split a port at runtime.  IOW we should define parameters
>without assigning them to config sets in the ABI itself.  And also we
>should make it in a way which will allow existing parameters to be
>reused in permanent/sort reset required/runtime modes.
>
>Does that make sense?

"IOW we should define parameters without assigning them to config sets
in the ABI itself" - I don't understand what do you mean by this.
