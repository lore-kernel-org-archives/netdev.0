From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Thu, 21 Jun 2007 11:47:20 -0400
Message-ID: <1182440840.5017.40.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182252616.21013.12.camel@johannes.berg>
	 <1182270006.4968.62.camel@localhost>
	 <1182338744.3714.59.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	lenb@kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:32102 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbXFUPrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 11:47:25 -0400
Received: by wx-out-0506.google.com with SMTP id t15so550758wxc
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 08:47:24 -0700 (PDT)
In-Reply-To: <1182338744.3714.59.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-20-06 at 13:25 +0200, Johannes Berg wrote:

> Ok. That's definitely a bug in nl80211 as we have it in development
> right now. 

Sorry, have never looked at that code.

> Btw, what happens if the group id gets larger than 31?

You can use setsockopt to set the multicast groups. What you cant do
with that is subscribe to many groups in one shot.
The call in iproute2 hasnt reflected this reality yet.

> I'd really like to be able to reserve multicast groups with special
> semantics too, especially I might want to permit/deny non-CAP_NET_ADMIN
> users from binding specific multicast groups. That isn't actually
> possible with netlink nor genetlink right now afaict.

This would be hard - but doable via SELinux interface. I think you
should be able to extend your tool to make calls to that interface.

> If we register multiple IDs then we'll end up filling up the generic
> netlink family space really soon. 

Theres a huge number of these groups; and not just that, but considering
that some genetlink users may not be interested in such multicast
groups, it is quiet usable to have many groups as long as we avoid
conflict.

> I was under the impression that
> generic netlink was basically open-ended because the family is a large
> enough number, but with this arbitrary limit on multicast groups that's
> really not true and we might run out of multicast groups fairly soon
> since most users of generic netlink will want at least one...
> 

The multicast issue wasnt well-attacked. We have a group magically
assigned to a user based on their allocated id. It should be feasible
to add an API to the kernel for registering for many groups and allow
user space to discover these groups before registering. Maybe thats
the path to proceed to.

cheers,
jamal





