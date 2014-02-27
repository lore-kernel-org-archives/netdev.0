From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How to best consolidate list of skbs (msdu) for receive?
Date: Thu, 27 Feb 2014 13:21:53 -0800
Message-ID: <1393536113.26794.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <530F85AE.8060002@candelatech.com>
	 <CAGVrzcajmuGQRi84WqWrxyUK2+xG1+b7EMTwRk4WpsDnp0B7qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:51258 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbaB0VVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:21:55 -0500
In-Reply-To: <CAGVrzcajmuGQRi84WqWrxyUK2+xG1+b7EMTwRk4WpsDnp0B7qQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 12:37 -0800, Florian Fainelli wrote:
> 2014-02-27 10:36 GMT-08:00 Ben Greear <greearb@candelatech.com>:
> > In ath10k, it can receive msdu (in rx raw mode, at least).  These show up
> > as a list of skb.  Currently they are just dropped as un-handled, and I
> > need to fix this.
> >
> > I think I need to consolidate this list into a single skb in order to pass
> > it up the stack.
> >
> > What is the preferred way to go about doing this?
> >
> > It seems I could just expand the head skb (pskb_expand_head) and copy the data from the others
> > onto the end of the head skb, but maybe there is a more efficient way to go about
> > doing this?
> 
> Some Ethernet drivers you would in general get multiple RX fragments
> for large frames, with the first fragment containing the headers, and
> then buffers of a few KiB, it is the driver responsibility to
> reassemble this as a large SKB with multiple fragments (grep for
> skb_fill_page_desc), would that work in your case?

Also skb_try_coalesce() might feet the need, if all you have are a list
of skb, rather than an array of page fragments
