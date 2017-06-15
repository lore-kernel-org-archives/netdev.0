From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Thu, 15 Jun 2017 15:55:12 -0700
Message-ID: <1497567312.14396.28.camel@perches.com>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <1497472613.18751.67.camel@perches.com>
         <1497472829.9377.13.camel@sipsolutions.net>
         <1497475096.18751.76.camel@perches.com>
         <1497565045.2518.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0092.hostedemail.com ([216.40.44.92]:55441 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750830AbdFOWzT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 18:55:19 -0400
In-Reply-To: <1497565045.2518.14.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 00:17 +0200, Johannes Berg wrote:
> On Wed, 2017-06-14 at 14:18 -0700, Joe Perches wrote:
> > On Wed, 2017-06-14 at 22:40 +0200, Johannes Berg wrote:
> > > On Wed, 2017-06-14 at 13:36 -0700, Joe Perches wrote:
> > > > 
> > > > Given you are adding a lot of these, it might be better
> > > > to add an exported function that duplicates most of
> > > > skb_put with a memset at the end.
> > > 
> > > Yeah, could be done. I'm not sure why you'd want to duplicate it
> > > rather
> > > than call it though? To make it about as fast?
> > 
> > Yeah, that and reduced stack use.
> > 
> > Dunno how performance sensitive these uses really are
> > but it seems some might be for slow cpu wireless APs in
> > both the rx and tx paths.
> 
> I haven't really checked now, but the wireless (mac80211) ones I saw
> weren't in the data TX/RX, only for management SKBs which are pretty
> much a slowpath.
> 
> Anyway, I guess you know how to propose a patch with this :-)

I'll wait as I don't want to cause patch conflicts.

> However, I think in that case there should be something like
> skb_pull_inline, so that the skb_put code here isn't all copied around,
> but just lives in a single place that gets inlined into skb_put() and
> skb_put_zero().

Seems sensible.
