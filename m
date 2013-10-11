From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: allow receiption on disabled port
Date: Fri, 11 Oct 2013 08:10:36 -0700
Message-ID: <20131011081036.63eb8f28@nehalam.linuxnetplumber.net>
References: <1381409570-1892-1-git-send-email-nbd@openwrt.org>
	<20131010133646.1bdd42c1@nehalam.linuxnetplumber.net>
	<52571481.5010907@openwrt.org>
	<20131010193551.462fc1f8@nehalam.linuxnetplumber.net>
	<5257D067.2050607@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:56763 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab3JKPKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 11:10:40 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so4377319pbb.10
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 08:10:39 -0700 (PDT)
In-Reply-To: <5257D067.2050607@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Oct 2013 12:18:15 +0200
Felix Fietkau <nbd@openwrt.org> wrote:

> On 2013-10-11 4:35 AM, Stephen Hemminger wrote:
> > This is what I was thinking would be better.
> > 
> > Don't want these packets leaking into PRE_ROUTEING chain or have
> > any chance to get flooded out other ports.
> > 
> > Compile tested only...
> > 
> > I could use another goto instead but that becomes spaghetti and
> > never like to jump back into a block.
> [...]
> >  forward:
> >  	switch (p->state) {
> > +	case BR_STATE_DISABLED:
> > +		if (!ether_addr_equal(p->br->dev->dev_addr, dest))
> > +			goto drop;
> Checking against the bridge device address isn't enough, WPA EAPOL
> packets are addressed to the wifi device MAC address.

Correct, this should be skb->dev->dev_addr which matchs against
the MAC address that frame arrived on.
