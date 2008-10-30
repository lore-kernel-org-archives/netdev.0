From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 6/6] netns: configurable number of initial network	namespaces
Date: Thu, 30 Oct 2008 15:41:17 -0700
Message-ID: <m1prlh1zaq.fsf@frodo.ebiederm.org>
References: <20081028174659.GF8471@thomson.net> <49075138.80808@trash.net>
	<49075488.8030002@thomson.net> <49075842.6000901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Chappelier <vivien.chappelier@thomson.net>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37009 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbYJ3Wox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 18:44:53 -0400
In-Reply-To: <49075842.6000901@trash.net> (Patrick McHardy's message of "Tue,
	28 Oct 2008 19:21:54 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Vivien Chappelier wrote:
>>    Yes; the linux-vrf patches had a new netlink message to create/remove the
>> equivalent of a network namespace (ip vrf add 1). I've not ported this feature
>> yet, so this patch is meant to provide another way of setting up networking
>> stacks without the need for a new process for each stack. The ability to
>> dynamically create/remove networking stacks from userspace would definitely be
>> useful.
>
> I see, I didn't realize the process that created a namespace
> needs to be kept running. So yes, creating standalone network
> namespaces seems to make sense

To be clear a reference needs to be kept to the network namespace.
Either by being the network namespace that new sockets are created in
task->nsproxy->netns or the network namespace of an open socket sock_net(sk).

If neither of those two conditions hold the network namespace count drops to
zero and it will be freed.  Probably not ideal if you are just doing routing.

Eric
