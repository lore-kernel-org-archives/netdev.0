From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: Fix userspace RTM_NEWLINK notifications.
Date: Mon, 14 Dec 2009 03:05:36 +0100
Message-ID: <1260756336.4041.3.camel@localhost.localdomain>
References: <m1fx7fmgyk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:52644 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbZLNCFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 21:05:47 -0500
In-Reply-To: <m1fx7fmgyk.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

> I received some bug reports about userspace programs having problems
> because after RTM_NEWLINK was received they could not immediate access
> files under /proc/sys/net/ because they had not been registered yet.
> 
> The original problem was trivially fixed by moving the userspace
> notification from rtnetlink_event() to the end of
> register_netdevice().
> 
> When testing that change I discovered I was still getting RTM_NEWLINK
> events before I could access proc and I was also getting RTM_NEWLINK
> events after I was seeing RTM_DELLINK.  Things practically guaranteed
> to confuse userspace.
> 
> After a little more investigation these extra notifications proved to
> be from the new notifiers NETDEV_POST_INIT and NETDEV_UNREGISTER_BATCH
> hitting the default case in rtnetlink_event, and triggering
> unnecessary RTM_NEWLINK messages.
> 
> rtnetlink_event now explicitly handles NETDEV_UNREGISTER_BATCH and
> NETDEV_POST_INIT to avoid sending the incorrect userspace
> notifications.

the POST_INIT and UNREGISTER_BATCH are not 2.6.32 features. They are
2.6.33 features and thus you need to create a separate patch for -stable
if you wanna fix the /proc access issue.

Regards

Marcel


