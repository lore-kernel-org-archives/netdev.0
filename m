From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC] tcp: allow timestamps even if SYN packet has tsval=0
Date: Sat, 14 Mar 2009 10:22:12 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903141015170.5797@wrl-59.cs.helsinki.fi>
References: <49B7ABF2.5040803@cosmosbay.com> <20090311.064710.255854254.davem@davemloft.net>
 <Pine.LNX.4.64.0903120858550.4697@wrl-59.cs.helsinki.fi>
 <20090313.142507.47563051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-207211498-1237018932=:5797"
Cc: dada1@cosmosbay.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58695 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbZCNIWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:22:15 -0400
In-Reply-To: <20090313.142507.47563051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-207211498-1237018932=:5797
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 13 Mar 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 12 Mar 2009 09:26:20 +0200 (EET)
> 
> > On Wed, 11 Mar 2009, David Miller wrote:
> > 
> > > From: Eric Dumazet <dada1@cosmosbay.com>
> > > Date: Wed, 11 Mar 2009 13:17:54 +0100
> > > 
> > > > So apparently WindowsXP sends a NULL tsval in SYN packet, then
> > > > subsequent packets get a real value (60498) in this case.
> > > > 
> > > > This seems to work on other OS as well, so is the following patch
> > > > considered evil ?  Do we have security concerns or only risking
> > > > windows client to have slightly wrong rtt estimation at the begining
> > > > of the tcp session ?
> > > 
> > > I think we'll have to accept this.
> > > 
> > > I don't see other systems blocking initial ts_ecn values of
> > > zero like we do.
> > 
> > What about the fact that PAWS could bite us leaving us a hung connection 
> > if timestamp changes too much when we get the first ACK? Though I doubt 
> > you can get windows to run long enough for this to become a problem if 
> > they always start from zero... ;-)
> 
> I really don't think it's a real issue, and Windows XP should be happy
> we're willing to try timestamps at all with it :-)

Right. Would it ever become a problem it would certainly possible to 
collect the first real timestamp and discard the bogus zero. We just need 
to be aware on this if some report about unable-to-connect appears once
the change gets larger exposure in wild.

There could be other broken things such as firewalls zeroing it in SYNs 
so the end host might not necessarily even be xp.

-- 
 i.
---696208474-207211498-1237018932=:5797--
