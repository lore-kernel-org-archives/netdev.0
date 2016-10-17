From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH v3 net-next 2/2] net: deprecate eth_change_mtu, remove
 usage
Date: Mon, 17 Oct 2016 16:07:12 -0400
Message-ID: <20161017200712.GN14983@redhat.com>
References: <20161017180027.4936fa15@jkicinski-Precision-T1700>
 <20161017.131513.135103913948374087.davem@davemloft.net>
 <20161017182049.4be802d1@jkicinski-Precision-T1700>
 <20161017.132553.1015830249902227215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kubakici@wp.pl, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33953 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755372AbcJQUHV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:07:21 -0400
Received: by mail-pf0-f169.google.com with SMTP id r16so59342897pfg.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 13:07:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161017.132553.1015830249902227215.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 01:25:53PM -0400, David Miller wrote:
> From: Jakub Kicinski <kubakici@wp.pl>
> Date: Mon, 17 Oct 2016 18:20:49 +0100
> 
> > Hm.  I must be missing something really obvious.  I just booted
> > net-next an hour ago and couldn't set MTU to anything larger than 1500
> > on either nfp or igb.  As far as I can read the code it will set the
> > max_mtu to 1500 in setup_ether() but none of the jumbo-capable drivers
> > had been touched by Jarod so far...
> 
> Indeed.
> 
> Jarod, this doesn't work.
> 
> I guess the idea was that if the driver overrides ndo_change_mtu and
> enforeced it's limits there, the driver would still work after your
> changes.
> 
> But that isn't what is happening, look at the IGB example.
> 
> It uses ether_setup(), which sets those new defaults, but now when
> the MTU is changed you enforce those default min/max before the
> driver's ->ndo_change_mtu() has a change to step in front and make
> the decision on it's own.
> 
> This means your changes pretty much did indeed break a lot of
> drivers's ability to set larger than a 1500 byte MTU.

Argh. Yeah, I see it now. I was primarily operating with the follow-on
patches also in play, which do touch all the ethernet drivers and set
max_mtu to match current behavior, didn't consider the max_mtu case where
only the initial patches were applied and the follow-on ones weren't. I've
sent that set, which should theoretically make this problem go away, but I
can also try to rework things if need be to restore intermediate jumbo
frames functionality. (And there are actually non-ethernet devices that
also call ether_setup and may or may not have larger than 1500 mtu that
aren't yet addressed by that follow-on set).

-- 
Jarod Wilson
jarod@redhat.com
