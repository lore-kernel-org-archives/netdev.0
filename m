From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v5 01/10] devlink: Add permanent config
 parameter get/set operations
Date: Tue, 31 Oct 2017 11:48:24 -0700
Message-ID: <20171031114824.0f54ef18@cakuba.netronome.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
        <1509374776-45869-2-git-send-email-steven.lin1@broadcom.com>
        <20171030170301.GE4115@nanopsycho.orion>
        <20171030151213.431dfbff@cakuba.netronome.com>
        <20171031071730.GB1972@nanopsycho.orion>
        <20171031010418.78fd4db1@laptop>
        <20171031090024.GE1972@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steve Lin <steven.lin1@broadcom.com>, netdev@vger.kernel.org,
        jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:42411 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932552AbdJaSse (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 14:48:34 -0400
In-Reply-To: <20171031090024.GE1972@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 10:00:24 +0100, Jiri Pirko wrote:
> Tue, Oct 31, 2017 at 09:04:18AM CET, kubakici@wp.pl wrote:
> >On Tue, 31 Oct 2017 08:17:30 +0100, Jiri Pirko wrote:  
> >> Mon, Oct 30, 2017 at 11:12:13PM CET, kubakici@wp.pl wrote:  
> >> >On Mon, 30 Oct 2017 18:03:01 +0100, Jiri Pirko wrote:  
> >> >I'm not sure what the status of the reconfig trigger patches for mlxsw
> >> >is, but we actually may need 3 config sets:
> >> > - current/runtime configurable, 
> >> > - requiring soft reset of the device/driver reinit;
> >> > - requiring hard reset/set on boot.
> >> >
> >> >Secondly, IMHO calling set/get parameters "permanent" is a bit
> >> >backwards.  One device may not be able to change max VF counts or MSIX
> >> >allocation without full reinit of PCIe blocks, but for others soft
> >> >reset is more than enough.  Port splitting is another example.  For 
> >> >NICs port splitting at runtime is usually not a priority in HW/FW
> >> >development, so some form of reset is generally required, while
> >> >switches can split a port at runtime.  IOW we should define parameters
> >> >without assigning them to config sets in the ABI itself.  And also we
> >> >should make it in a way which will allow existing parameters to be
> >> >reused in permanent/sort reset required/runtime modes.
> >> >
> >> >Does that make sense?    
> >> 
> >> "IOW we should define parameters without assigning them to config sets
> >> in the ABI itself" - I don't understand what do you mean by this.  
> >
> >OK, whether the setting is permanent or not - is device specific.
> >
> >I'm basically asking to remove the "PERM" from the names and indicate
> >which config set (of the 3 enumerated above) user wants it applied in a
> >separate attribute.  
> 
> Yesh, would be good if driver could indicate which option is of what
> type and devlink should expose this information to the user.

Sounds like there would be one dump with all settings each marked with
a flag indicating if it's permanent/init time or run time.  How would
users check the current vs pending configurations?

> But it probably should be flags. Driver may provide possibility to
> configure for example VF count as runtime and also permanent option.
> User should pass the correct flags along the set message so the driver
> knows what to set. Makes sense?

SGTM.  And we can also extend port splitting to take the same flags? :)
