From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/6] openvswitch: VXLAN tunneling.
Date: Thu, 25 Jul 2013 16:41:07 -0700 (PDT)
Message-ID: <20130725.164107.764173217829254913.davem@davemloft.net>
References: <1374688826-14199-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab3GYXlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 19:41:10 -0400
In-Reply-To: <1374688826-14199-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Wed, 24 Jul 2013 11:00:26 -0700

> First two patches extends vxlan so that openvswitch can
> share vxlan udp port with vxlan module. Rest of patches
> refactors vxlan data plane so that ovs can share that
> code with vxlan module.
> Last patch adds vxlan-vport to openvswitch.

I'm mostly fine with this patch series and I assume Stephen will
eventually take it in via his vxlan tree.

However I do have one issue with patch #1 that I'd like to ask you to
consider.

You're doing two seperate things there.  First, you're abstracting out
the handler bits at one level of indirection via "struct
vxlan_handler" Second, you're adjusting how the headers are handled
in the handler paths.

I understand why you're doing the second part, to accomodate multiple
handlers properly.

But I think it would be much better to do this in two stages.

The first stage does the "struct vxlan_handler" abstraction and then
the second stage reworks how packet headers get adjusted.

I'm suggesting this for the purposes of bisectability.  I believe that
the header handling adjustments are the part that are going to be the
most dangerous for regressions.  So it would be best if we could
exactly pinpoint that exact change as causing problems in the future.

When you split this up, in the first patch, enforce only one handler
at a time.  You can remove this restriction as part of the second
patch.

I frankly think that this will make these changes easier to review and
audit as well.

How does that sound?
