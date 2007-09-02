From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: RTNL: assertion failed at net/core/dev.c
Date: Sun, 2 Sep 2007 17:13:00 +0100
Message-ID: <20070902171300.2f4814d1@oldman>
References: <alpine.DEB.0.999.0709021754290.7103@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47424 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756342AbXIBQNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 12:13:12 -0400
In-Reply-To: <alpine.DEB.0.999.0709021754290.7103@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Sep 2007 18:05:33 +0200 (CEST)
Christian Kujau <lists@nerdbynature.de> wrote:

> Wow, I should really update more often. Skipping the last -rc versions 
> AND adding a new device (zd1211rw) to the box turns out to be quite 
> interesting ([0],[1]).
> 
> However, this time loading of a (proprietary) module is involved. Knowing
> that lkml cannot really help here (and I should contact vmware), I just 
> wanted to let you netdev guys know, because the only occurences I found 
> on the net were from 1999, but given the amount of changes currently 
> going into net/ I thought this might be interesting:
> 
> [15604.137408] RTNL: assertion failed at net/core/dev.c (2595)
> [15604.137772]  [<c0106aaa>] show_trace_log_lvl+0x1a/0x30
> [15604.138121]  [<c0107682>] show_trace+0x12/0x20
> [15604.138449]  [<c01076a5>] dump_stack+0x15/0x20
> [15604.138807]  [<c038c612>] __dev_set_promiscuity+0xc2/0xd0
> [15604.139163]  [<c038c9bb>] dev_set_promiscuity+0x1b/0x40
> [15604.139515]  [<f91cb3fb>] VNetBridgeStartPromisc+0x2b/0x50 [vmnet]

Vendor module calls kernel api incorrectly. dev_set_promiscuity requires
that the calling thread hold rtnl mutex (ie call rtnl_lock). It's their bug,
netdev doesn't want to hear about it.
