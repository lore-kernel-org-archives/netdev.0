From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Thu, 21 Jun 2007 13:08:12 -0600
Message-ID: <m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46362 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbXFUTIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 15:08:46 -0400
In-Reply-To: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
	(Patrick McHardy's message of "Wed, 20 Jun 2007 20:00:22 +0200
	(MEST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> These two patches contain a first short at secondary unicast address support.
> I'm still working on converting macvlan as an example, but since I'm about to
> leave for tonight I thougth I'd get them out for some comments now.
>
> The patch adds two new functions dev_unicast_add and dev_unicast_delete to
> add/remove addresses. Similar to dev_mc_add/dev_mc_delete they do refcounting
> of the addresses and the address on a list associated with the device.
>
> dev_address_upload is responsible for uploading both the multicast and
> unicast list to the device. Devices that are capable of filtering multiple
> unicast addresses need to provide a function dev->set_address_list that
> deals with setting both unicast and multicast address filters. This seemed
> like the easiest way for chips containing filters that can be used for
> any address type, also parts of the logic when to use HW filters is similar
> for unicast and multicast addresses. Devices not providing this function
> are put in promiscous mode when secondary addresses are present and the
> old set_multicast_list function is called to take care of multicast
> filtering.
>
> The dev_uc_list structure is kept similar to dev_mc_list to allow easier
> integration in existing "fill address filters" loops.
>
> E1000 is converted as an example, the patch worked fine in some limited
> testing.

>
> Comments welcome.

I'm trying to understand what the point of this patch is.

In once sense I find the concept of filtering and listening for multiple
mac addresses very interesting, especially if we could break out different
streams of traffic by destination mac address into separate network devices.
This would remove the need to any kind of ethernet tunnel and makes multiple
network namespaces much more pleasant.

However this just seems to allow a card to decode multiple mac addresses
which in some oddball load balancing configurations may actually be
useful, but it seems fairly limited.

Do you have a specific use case you envision for this multiple mac
functionality?

Eric
