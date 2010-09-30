From: Roger Luethi <rl@hellgate.ch>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 10:07:04 +0200
Message-ID: <20100930080703.GA10827@core.hellgate.ch>
References: <20100929113757.GA23755@core.hellgate.ch>
 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14.bluewin.ch ([195.186.19.62]:48664 "EHLO
	mail14.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab0I3IOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 04:14:09 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
> On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> wrote:
> > I noticed packets for unknown VLANs getting silently dropped even in
> > promiscuous mode (this is true only for the hardware accelerated path).
> > netif_nit_deliver was introduced specifically to prevent that, but the
> > function gets called only _after_ packets from unknown VLANs have been
> > dropped.
> 
> Some drivers are fixing this on a case by case basis by disabling
> hardware accelerated VLAN stripping when in promiscuous mode, i.e.:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5f6c01819979afbfec7e0b15fe52371b8eed87e8
> 
> However, at this point it is more or less random which drivers do
> this.  It would obviously be much better if it were consistent.

My understanding is this. Hardware VLAN tagging and stripping can always be
enabled. The kernel passes 802.1Q information along with the stripped
header to libpcap which reassembles the original header where necessary.
Works for me.

Hardware VLAN filtering, on the other hand, must be disabled in promiscuous
mode. But doing that in the driver makes no difference now as the current
VLAN code drops the packets so preserved before they are passed to the pcap
interface. That appears to be a bug.

Roger
