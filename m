From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 0/5] netns: allow to identify peer netns
Date: Wed, 02 Jul 2014 13:09:58 -0700
Message-ID: <87simj7ca1.fsf@x220.int.ebiederm.org>
References: <537327F1.4060603@6wind.com>
	<1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43219 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbaGBUNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 16:13:23 -0400
In-Reply-To: <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
	(Nicolas Dichtel's message of "Wed, 2 Jul 2014 13:59:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> The goal of this serie is to be able to multicast netlink messages with an
> attribute that identify a peer netns.
> This is needed by the userland to interpret some informations contained in
> netlink messages (like IFLA_LINK value, but also some other attributes in case
> of x-netns netdevice (see also
> http://thread.gmane.org/gmane.linux.network/315933/focus=316064)).
>
> Each network namespaces allocates its own ids for other netns (including
> itself). The user can retrieve these ids via a new netlink messages, but only
> if he has a FD which points to this netns. Dump is not implemented so that a
> user cannot get the whole netns list.
>
> The goal of this RFC is mainly to validate the principle, ie patch 1/5 and 2/5.
> Patch 3/5 and 4/5 shows an example of how to use these ids in rtnetlink
> messages. And patch 5/5 shows that the netlink messages can be symetric between
> a GET and a SET.

This approach fundamentally breaks process migration, and calls for a
namespace of namespaces.

Which means this is a major mess that really isn't going to work because
it generates more problems than it solves.

Eric
