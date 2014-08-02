From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Sat, 02 Aug 2014 15:16:30 -0700 (PDT)
Message-ID: <20140802.151630.929949940730781279.davem@davemloft.net>
References: <1406851057-1593-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152AbaHBWQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:16:31 -0400
In-Reply-To: <1406851057-1593-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 31 Jul 2014 16:57:37 -0700

> Following patch adds mask cache so that we do not need to iterate over
> all entries in mask list on every packet. We have seen good performance
> improvement with this patch.

How much have you thought about the DoS'ability of openvswitch's
datastructures?

What are the upper bounds for performance of packet switching?

To be quite honest, a lot of the openvswitch data structures
adjustments that hit my inbox seem to me to only address specific
situations that specific user configurations have run into.

It took us two decades, but we ripped out the ipv4 routing cache
because external entities could provoke unreasonable worst case
behavior in routing lookups.

With openvswitch you guys have a unique opportunity to try and design
all of your features such that they absolutely can use scalable
datastructures from the beginning that provide reasonable performance
in the common case and precise upper bounds for any possible sequence
of incoming packets.

New features tend to blind the developer to the eventual long term
ramifications on performance.  Would you add a new feature if you
could know ahead of time that you'll never be able to design a
datastructure which supports that feature and is not DoS'able by a
remote entity?
