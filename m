From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: changing dev->needed_headroom/needed_tailroom?
Date: Tue, 20 Aug 2013 09:29:39 -0700
Message-ID: <20130820092939.7d4cad35@nehalam.linuxnetplumber.net>
References: <1374850210.8248.59.camel@jlt4.sipsolutions.net>
	<1375433758.24371.20.camel@deadeye.wl.decadent.org.uk>
	<1375449082.3927.5.camel@edumazet-glaptop>
	<1375711240.8120.11.camel@jlt4.sipsolutions.net>
	<CAGVrzcaGV6AqLTAxpM6zMv7_C-LNxp-WNg+J47d7a9S+Ca1bDw@mail.gmail.com>
	<20130820092013.6ca909e2@nehalam.linuxnetplumber.net>
	<1377015897.13829.16.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:52657 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab3HTQ3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 12:29:42 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so599808pdi.14
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 09:29:42 -0700 (PDT)
In-Reply-To: <1377015897.13829.16.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Aug 2013 18:24:57 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Tue, 2013-08-20 at 09:20 -0700, Stephen Hemminger wrote:
> 
> > All code must check for needed headroom first, and copy packet
> > if space is not available. Since excess headroom is always safe,
> > most devices just always use the same worst case headroom.
> > 
> > Even with your changes this will still be necessary since packets will
> > be still in flight while features change.
> 
> I agree, it will always be necessary. I guess the question boils down to
> whether/what N bytes headroom more or less actually make a difference.
> 
> The wireless stack currently sets needed_headroom to 34 or so I think,
> but I will need to increase by 8 which was why I had this question to
> start with. However, those 34 are an absolute worst case - in most cases
> it's much less...
> 
> So I suppose the other question we should ask is will increasing from
> ~34 to ~42 make a significant different that it's worth thinking about
> avoiding it in the common cases at all?
> 
> johannes
> 

The only thing that might matter is alignment. but +/- 8 bytes isn't going
to change that.
