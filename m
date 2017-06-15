From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Fri, 16 Jun 2017 00:17:25 +0200
Message-ID: <1497565045.2518.14.camel@sipsolutions.net>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <1497472613.18751.67.camel@perches.com>
         <1497472829.9377.13.camel@sipsolutions.net>
         <1497475096.18751.76.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53942 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751667AbdFOWR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 18:17:27 -0400
In-Reply-To: <1497475096.18751.76.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 14:18 -0700, Joe Perches wrote:
> On Wed, 2017-06-14 at 22:40 +0200, Johannes Berg wrote:
> > On Wed, 2017-06-14 at 13:36 -0700, Joe Perches wrote:
> > > 
> > > Given you are adding a lot of these, it might be better
> > > to add an exported function that duplicates most of
> > > skb_put with a memset at the end.
> > 
> > Yeah, could be done. I'm not sure why you'd want to duplicate it
> > rather
> > than call it though? To make it about as fast?
> 
> Yeah, that and reduced stack use.
> 
> Dunno how performance sensitive these uses really are
> but it seems some might be for slow cpu wireless APs in
> both the rx and tx paths.

I haven't really checked now, but the wireless (mac80211) ones I saw
weren't in the data TX/RX, only for management SKBs which are pretty
much a slowpath.

Anyway, I guess you know how to propose a patch with this :-)

However, I think in that case there should be something like
skb_pull_inline, so that the skb_put code here isn't all copied around,
but just lives in a single place that gets inlined into skb_put() and
skb_put_zero().

johannes
