From: Joe Perches <joe@perches.com>
Subject: Re: [RFC 1/3] networking: make skb_put & friends return void
 pointers
Date: Fri, 16 Jun 2017 03:39:18 -0700
Message-ID: <1497609558.10546.5.camel@perches.com>
References: <20170615221217.16510-1-johannes@sipsolutions.net>
         <20170615221217.16510-2-johannes@sipsolutions.net>
         <871sqke5co.fsf@miraculix.mork.no>
         <1497602577.2622.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0216.hostedemail.com ([216.40.44.216]:33046 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752436AbdFPKjV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 06:39:21 -0400
In-Reply-To: <1497602577.2622.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 10:42 +0200, Johannes Berg wrote:
> On Fri, 2017-06-16 at 09:53 +0200, Bjørn Mork wrote:
> 
> > There seem to be a large number of places where the char pointer was
> > used directly. Not that I have any strong opinion either way, but
> > adding lots of ugly casts like this seems to contradict the whole
> > purpose of this change?:
> > > -			*skb_put(info->rx_skb, 1) = x;
> > > +			*(u8 *)skb_put(info->rx_skb, 1) = x;
> > >  			inb(iobase + DATA_H);
> > >  			info->rx_count--;
> > >  
> > 
> > That does not look any better in my eyes, and there are ... what?
> > ... hundreds of them?
> 
> Yeah it's a bit of a trade-off. There are ~140 of these, but >200 of
> the removed casts. Joe also suggested we could replace these by
> skb_put_u8() or so, which would be indeed be nicer. I can send a patch,
> it's pretty simple.

I would suggest avoiding using skb_put_u8 as it
would suggest there should be skb_put_u16 etc
