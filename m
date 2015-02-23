From: Jonas Johansson <jonasj76@gmail.com>
Subject: Re: [PATCH net-next 1/2] dsa: bonding: implement HW bonding
Date: Mon, 23 Feb 2015 16:52:06 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1502231646190.18726@hellgate.skynet>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com> <1424429473-4601-2-git-send-email-jonasj76@gmail.com> <CAE4R7bCme-O6kkCWgmK_XXXfyi_uej8SvbVzDY7Q+WFp2STyRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jonas Johansson <jonasj76@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	=?ISO-8859-2?Q?Ji=F8=ED_P=EDrko?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:41034 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbbBWP4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 10:56:13 -0500
Received: by lbiz11 with SMTP id z11so19330687lbi.8
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 07:56:12 -0800 (PST)
In-Reply-To: <CAE4R7bCme-O6kkCWgmK_XXXfyi_uej8SvbVzDY7Q+WFp2STyRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 21 Feb 2015, Scott Feldman wrote:

> On Fri, Feb 20, 2015 at 2:51 AM, Jonas Johansson <jonasj76@gmail.com> wrote:
>> From: Jonas Johansson <jonas.johansson@westermo.se>
>>
>> This patch will implement hooks for hardware bonding support for the DSA
>> driver. When the team driver adds a DSA slave port the port will be assigned
>> a bond group id and the DSA slave driver can setup the hardware. When team
>> changes the port state (enabled/disabled) the DSA slave driver is able to
>> use the attach/detach callback which will allow the hardware to change the
>> hardware settings to reflect the state.
>>
>> Added DSA hooks:
>>  bond_add_group: To add a port to a bond group
>>  bond_del_group: To remove a port from a bond group
>>  bond_attach: To mark the port in a bond group as attached/active
>>  bond_detach: To unmark the port in a bond group as detach/inactive
>>
>> Added new network device hooks:
>>  ndo_bond_attach: To attach a device to a bond group.
>>  ndo_bond_detach: To detach a device from a bond group.
>>
>> Team:
>>  Added callback to ndo_bond_attach when port is enabled.
>>  Added callback to ndo_bond_detach when port is disabled.
>>
>> Added DSA notifier:
>>  Listening on NETDEV_CHANGEUPPER to add or deleta a port to/from a bond group.
>
> Hi Jonas,
>
> Cc:'ing Andy as he mentioned at netdev01 he was looking into something
> similar for switchdev.
>
> My comments are along the lines of the others:
>
> Can we up-level this not for just DSA but for switchdev in general?  I
> think the requirements are:
>
> 1) It should work for team or bonding.
>
> 2) Port driver needs to know a) bond membership, and b) port (active,
> inactive) status, at least for 802.3ad.
>
> 3) Try to avoid adding new ndo ops if possible, and rather use what's there.
>
> It took me a bit to figure out your new ndo ops in this patch.  Going
> by the name ndo_bond_attach/dettach, I thought these were for port
> membership, but you're using them for port status change.  So the name
> was confusing.  Since you already have port membership covered with
> netdevice event NETDEV_CHANGEUPPER, can we also adapt port status
> change into netdevice event NETDEV_BONDING_INFO?  (See
> netdev_bonding_info_change()).
>
> -scott
>
I think aiming for switchdev is a good ides. I will look into this and if 
NETDEV_BONDING_INFO can be used instead if adding the new ndo fops. I'm on 
vacation atm, so I will start look into it the next week. Thanks for all 
the good input.
- Jonas
