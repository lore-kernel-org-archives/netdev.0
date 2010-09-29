From: Jesse Gross <jesse@nicira.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Wed, 29 Sep 2010 10:44:26 -0700
Message-ID: <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
References: <20100929113757.GA23755@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59859 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442Ab0I2Ro1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 13:44:27 -0400
Received: by iwn5 with SMTP id 5so1289061iwn.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 10:44:27 -0700 (PDT)
In-Reply-To: <20100929113757.GA23755@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> wrote:
> I noticed packets for unknown VLANs getting silently dropped even in
> promiscuous mode (this is true only for the hardware accelerated path).
> netif_nit_deliver was introduced specifically to prevent that, but the
> function gets called only _after_ packets from unknown VLANs have been
> dropped.

Some drivers are fixing this on a case by case basis by disabling
hardware accelerated VLAN stripping when in promiscuous mode, i.e.:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5f6c01819979afbfec7e0b15fe52371b8eed87e8

However, at this point it is more or less random which drivers do
this.  It would obviously be much better if it were consistent.
