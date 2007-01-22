From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Mon, 22 Jan 2007 10:20:47 -0500
Message-ID: <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
	 <1169056884.9175.66.camel@johannes.berg> <20070122112613.GA3038@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Dan Williams" <dcbw@redhat.com>, "Jiri Benc" <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:39783 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbXAVPUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 10:20:49 -0500
Received: by py-out-1112.google.com with SMTP id a29so645276pyi
        for <netdev@vger.kernel.org>; Mon, 22 Jan 2007 07:20:48 -0800 (PST)
To: "Marcelo Tosatti" <marcelo@kvack.org>
In-Reply-To: <20070122112613.GA3038@dmt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/22/07, Marcelo Tosatti <marcelo@kvack.org> wrote:
> On Wed, Jan 17, 2007 at 06:01:24PM +0000, Johannes Berg wrote:
> > On Wed, 2007-01-17 at 12:43 -0500, Dan Williams wrote:
> >
> > > I said "mostly" fullmac.  Sort of like ipw2100 (IIRC) is softmac but it
> > > does all the association stuff in firmware.  It doesn't fit fullmac, but
> > > it's a lot more fullmac than atheros.  There isn't any management frame
> > > processing, it doesn't do any data frame processing.
> >
> > Right. I hadn't looked at data frames but suspected this is the case.
> >
> > > The 8388 architecture is typical of a thick firmware architecture, where
> > > the firmware handles all 802.11 MAC management tasks.  The host driver
> > > downloads standard 802.3 frames to the firmware to be transmitted over
> > > the link as 802.11 frames.
> > >
> > > I thought these 2 things were essentially _the_ definition of fullmac,
> > > please correct me if I'm wrong.
> >
> > Well we'll need more terms here. I had a short chat with Jouni and we
> > agree that what the Marvell card is doing is exposing the MLME
> > interface, and what d80211 is doing is implementing most of the MLME.
> >
> > I guess the thing I'm saying is that exposing the MLME interface which
> > changes fairly frequently is a bad thing and I'd love to have firmware
> > that exposes lower level stuff like .
> >
> > > Perhaps I just don't understand how flexible d80211 has become; when we
> > > last were talking about it 8 months ago, it appears that it could not
> > > handle parts that did significant pieces of work in firmware, like the
> > > 8388 does.  Do we have the functionality in d80211 yet to handle pieces
> > > that are a full mix of hybrid full/soft mac?
> >
> > No, we don't have that yet, and we might never have. But I think I'm
> > starting to understand the issues at hand a bit better and it seems that
> > we'll need cfg80211 to be redefined.
>
> So using the d80211 stack is completly out of question?

What is the general solution for 802.11s? I'm working on an embedded
design that would benefit from 11s support and I'd rather not have to
roll my own mesh implementation in user space. I'd also like to get an
idea of what kind of hardware I need to design onto my board given
that the 8388 is not available general consumption. My system has
plenty of power and CPU available so a softmac type 11s solution is
the most cost effective. It seems to me that the design of a software
based 11s stack should be coordinated with the 8388 firmware one.

> Another detail is the way we deal with mesh networking: a separate
> device "mshX" is created, and that certainly does not fit d80211?

-- 
Jon Smirl
jonsmirl@gmail.com
