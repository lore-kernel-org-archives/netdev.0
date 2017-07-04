From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net 0/3] nfp: port enumeration change and FW ABI
 adjustment
Date: Tue, 4 Jul 2017 13:52:07 -0700
Message-ID: <20170704135207.51adade5@cakuba.netronome.com>
References: <20170704092721.780-1-jakub.kicinski@netronome.com>
        <20170704.032949.30168457068908035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35471 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752169AbdGDUwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 16:52:11 -0400
Received: by mail-pg0-f43.google.com with SMTP id j186so114172829pge.2
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 13:52:11 -0700 (PDT)
In-Reply-To: <20170704.032949.30168457068908035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Jul 2017 03:29:49 -0700 (PDT), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Tue,  4 Jul 2017 02:27:18 -0700
> 
> > This set changes the way ports are numbered internally to avoid MAC address
> > changes and invalid link information when breakout is configured.  Second
> > patch gets rid of old way of looking up MAC addresses in device information
> > which caused all this confusion.
> > 
> > Patch 3 is a small adjustment to the new FW ABI version we introduced in
> > this release cycle.
> > 
> > 
> > To clarify these are intended for 4.13, naturally.  
> 
> net-next is closed, and it looks like these are not really bug fixes
> but a behavior adjustment and therefore more like a new feature.

Ah, silly me, I had these ready on Friday but didn't want to participate
in the just-before-the-merge-window rush :(

Could you be pursued to take patch 3?  Without it our current Flower
firmware does not work with the 5.x ABI, if we get a kernel released in
this state we will have to bump the ABI again, effectively making the
4.13 Flower offload unusable :(

Patch 1 fixes ethtool dumping and configuring wrong ports.  I had a
report from someone using a 2x40 card where one port was broken out to
4x10 and ethtool was swapping info on the 40G port and one of the 10G
ports.  I didn't notice this in testing, because I was testing with two
NFPs back to back, so the port swap sort of cancelled itself out.  I
should've made it clearer in the commit message that the patch
effectively fixes the association between management FW idea of ports
and the netdevs.  This is lower priority than patch 3, though.

Patch 2 can be dropped, I tossed it in unnecessarily.
