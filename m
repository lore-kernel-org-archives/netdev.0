From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] openvswitch: properly refcount vport-vxlan module
Date: Tue, 01 Dec 2015 16:41:48 +0100
Message-ID: <1448984508.3380707.454779977.1FF45EA1@webmail.messagingengine.com>
References: <2658801f06f24c242c40f223b1164e61be44974a.1448882748.git.pabeni@redhat.com>
 <1448971437.3330290.454583417.56E794A4@webmail.messagingengine.com>
 <1448975955.4459.4.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49546 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752483AbbLAPlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 10:41:49 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id A6C76212DE
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 10:41:48 -0500 (EST)
In-Reply-To: <1448975955.4459.4.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015, at 14:19, Paolo Abeni wrote:
> Currently all the vport_ops list manipulation functions are protected by
> the ovs_lock (even the lookup): the scenario described above should not
> be possible.

This makes all sense and it seems no use-after-free is possible at all
(I didn't notice the lookup path takes the lock). But the macro still
looks ugly and modifies a global struct with a per-module linked symbol.
David, why exactly didn't you like the first patch? Seems to me it does
what is actually needed.

Thanks,
Hannes
