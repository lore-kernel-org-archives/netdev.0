From: Jiri Pirko <jiri@resnulli.us>
Subject: HW communication debugging interface - ideas?
Date: Wed, 30 Sep 2015 15:51:41 +0200
Message-ID: <20150930135141.GF2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34386 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbI3Nvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 09:51:44 -0400
Received: by wicfx3 with SMTP id fx3so198668112wic.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:51:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave/all.

There is quite common for drivers to speak with HW using "packet-like"
messages. In our case, we put message into skb and push that out as
an ordinary packet. HW then sends us reply in a packet, similar to other
rx-ed packets.

It makes sense to monitor this communication. Not only for debugging
during development, but mainly for collecting data for error reports
from users.

Very cool usecase is to teach wireshark to parse this communication so
one can actually see online what is going on.

Now the question is, what is the correct way to expose this
communication to userspace. Naturally, this interface should be read-only.
Also, the interface should be generic enough so it can be used for all
drivers, including non-net drivers.

1) Special monitoring netdev.
Might make sense to use a separate netdev. Is is easy to tap the
communication. Driver would just create new netdev and push incoming and
outgoing messages there. Downside is that there would be needed to wrap the
messages with some metadata header, which seems quite odd.

2) generic Netlink (genl) interface. Easy to put metadata in, including the
device identificator (pci address). User then can use nlmon in order to
be able to use wireshark to see the netlink messages.

Looks like 2) might be viable, well-defined, generic interface to carry
this info. What do you think? Does this make sense?

Thanks!

Jiri
