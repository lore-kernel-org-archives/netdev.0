From: Jon Stanley <jstanley@rmrf.net>
Subject: Re: [patch net] vlan: fix bond/team enslave of vlan challenged slave/port
Date: Mon, 15 Oct 2012 10:53:30 -0400
Message-ID: <CAJtaB1ugcEp13LYX6yJL0DX4EVX53h7MyumzRGDLZ_u8fyu_WA@mail.gmail.com>
References: <1350225056-14144-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:58062 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab2JOOxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 10:53:31 -0400
Received: by mail-qa0-f46.google.com with SMTP id c26so1340710qad.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 07:53:30 -0700 (PDT)
In-Reply-To: <1350225056-14144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 14, 2012 at 10:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:

> In vlan_uses_dev() check for number of vlan devs rather than existence
> of vlan_info. The reason is that vlan id 0 is there without appropriate
> vlan dev on it by default which prevented from enslaving vlan challenged
> dev.

Thanks for the patch!

However, I'm now running into a new issue. Note that I've backported
this to an older kernel (3.3.2, eww), but I don't *think* that matters
for this. Now I'm getting a "refused to change device type" which
looks like it comes from around here:

                        res = netdev_bonding_change(bond_dev,
                                                    NETDEV_PRE_TYPE_CHANGE);
                        res = notifier_to_errno(res);
                        if (res) {
                                pr_err("%s: refused to change device type\n",
                                       bond_dev->name);

I'm not quite smart enough to figure out what's going on here. FWIW,
looking back in history it looks like the only relevant change from
here to mainline is the replacement of netdev_bonding_change() with
direct calls to call_netdevice_notifiers().

Again, .let me know if more info is needed, and thanks for the quick response!
