From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Mon, 12 Jan 2009 11:18:48 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901121111420.24748@wrl-59.cs.helsinki.fi>
References: <20090111212303.GA8612@outpost.ds9a.nl>
 <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com>
 <20090111224541.GA10848@outpost.ds9a.nl> <20090111225427.GA7004@ioremap.net>
 <20090111230824.GB10848@outpost.ds9a.nl> <20090111231859.GA8309@ioremap.net>
 <20090111235001.536a858d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	bert hubert <bert.hubert@netherlabs.nl>,
	"H. Willstrand" <h.willstrand@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56349 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbZALJSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 04:18:50 -0500
In-Reply-To: <20090111235001.536a858d.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 11 Jan 2009, Bill Fink wrote:

> On Mon, 12 Jan 2009, Evgeniy Polyakov wrote:
> 
> > On Mon, Jan 12, 2009 at 12:08:24AM +0100, bert hubert (bert.hubert@netherlabs.nl) wrote:
> > > I fully understand. Sometimes I have to talk to stupid devices though. What
> > > I do find is the TCP_INFO ioctl, which offers this field in struct tcp_info:
> > > 
> > >         __u32   tcpi_unacked;
> > > 
> > > Which comes from:
> > > 
> > > struct tcp_sock {
> > > ...
> > >         u32     packets_out;    /* Packets which are "in flight"        */
> > > ...
> > > }
> > > 
> > > If this becomes 0, perhaps this might tell me everything I sent was acked?
> > 
> > 0 means that there are noin-flight packets, which is effectively number
> > of unacked packets. So if your application waits for this field to
> > become zero, it will wait for all sent packets to be acked.
> 
> I use this type of strategy in nuttcp, and it seems to work fine.
> I have a loop with a small delay and a check of tcpi_unacked, and
> break out of the loop if tcpi_unacked becomes 0 or a defined timeout
> period has passed.

Checking tcpi_unacked alone won't be reliable. The peer might be slow 
enough to advertize zero window for a short period of time and during 
that period you would have packets_out zero...


-- 
 i.
