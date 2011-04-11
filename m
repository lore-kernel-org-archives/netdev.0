From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: extending feature word.
Date: Mon, 11 Apr 2011 11:54:59 -0700
Message-ID: <20110411115459.13ac3c73@nehalam>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	<20110408100535.GB10565@rere.qmqm.pl>
	<BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com>
	<20110410101954.GA23753@rere.qmqm.pl>
	<BANLkTimFzTGKmhfRxzEUt_LwrnhAaetU5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36508 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab1DKSzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 14:55:02 -0400
In-Reply-To: <BANLkTimFzTGKmhfRxzEUt_LwrnhAaetU5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Apr 2011 11:45:05 -0700
Mahesh Bandewar <maheshb@google.com> wrote:

> >> That is right! making it an array doesn't really buy us anything
> >> unless there is a uniform way of managing all the bits spread across
> >> multiple words inside that array. This was the reason why I have
> >> changed that array into a bitmap in the patch that I have posted
> >> earlier. This way the upper limit (currently only 32 bits) will be
> >> removed and we'll have a long term solution. There will be little bit
> >> of work involved but 'doing-things-right' has cost associated.  
> >
> > I really don't like the bitmap idea. It multiplies the amount of code
> > needed to manipulate multiple bits at once --- and that's a common
> > thing for drivers to do. Almost every driver that needs ndo_fix_features
> > will clear sets --- checkumming set, TSO set, all TX offloads set, ...
> >  
> Should the added code be of any concern? If that is happening in the
> control-path and does not affect the data-path as such; those added
> instructions is a cost of added flexibility to we got through bitmap.
> If performance is not at risk then that shouldn't be a problem.

Just to be dense... What is wrong with just using u64?

-- 
