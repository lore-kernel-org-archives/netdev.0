From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: Prevent IPv6 link local address on enslaved devices
Date: Fri, 08 Jan 2016 12:51:17 -0800
Message-ID: <5842.1452286277@famine>
References: <1452281616-14447-1-git-send-email-kheiss@gmail.com> <4679.1452282961@famine> <CAGugRbXT3jXw1-42Nz6ci-PS7z+HUj_fG2zcwK45dM6pb+RnqQ@mail.gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:57139 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703AbcAHUvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 15:51:21 -0500
In-reply-to: <CAGugRbXT3jXw1-42Nz6ci-PS7z+HUj_fG2zcwK45dM6pb+RnqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karl Heiss <kheiss@gmail.com> wrote:

>On Fri, Jan 8, 2016 at 2:56 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>> Karl Heiss <kheiss@gmail.com> wrote:
[...]
>>>@@ -1216,7 +1215,6 @@ static void bond_upper_dev_unlink(struct net_device *bond_dev,
>>>                                 struct net_device *slave_dev)
>>> {
>>>       netdev_upper_dev_unlink(slave_dev, bond_dev);
>>>-      slave_dev->flags &= ~IFF_SLAVE;
>>>       rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
>>> }
>>
>>         Will this change cause issues for user space monitoring of the
>> RTM_NEWLINKs, as now the message will have IFF_SLAVE in the flags for
>> both the "link" and "unlink" cases?  How would link be distinguished
>> from unlink?
>>
>>         Since the unlink happens only in __bond_release_one or in the
>> case of a failure within bond_enslave, does clearing the flag in
>> bond_upper_dev_unlink cause any actual issues?
>>
>>         -J
>>
>
>Oops.  You are correct that the RTM_NEWLINK would appear to be identical to
>the link case.  I had originally done this to prevent any NETDEV_CHANGE events
>from causing the link local address and subsequent neighbor advertisements just
>as the device is unlinked.  However, the bond_upper_dev_unlink() changes were a
>result of speculation, not actual observation.
>
>If we feel that we are safe from any NETDEV_CHANGE events and/or the
>consequences during unlink, I am fine with leaving the bond_upper_dev_unlink()
>code as-is.

	I looked briefly, and I don't see a source of NETDEV_CHANGE
notifiers between the bond_upper_dev_unlink and dev_close calls in
__bond_release_one.  Note that dev_set_promiscuity / allmulti do end up
in __dev_notify_flags, but it excludes NETDEV_CHANGE for PROMISC and
ALLMULTI, so I think that's not an issue.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
