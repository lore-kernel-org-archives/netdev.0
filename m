From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH/RFC] [v3] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Sun, 30 Dec 2007 11:43:37 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712301139150.31698@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie> <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
 <20071221.031400.194877955.davem@davemloft.net> <20071221133106.GA7995@nuim.ie>
 <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
 <20071230011500.GA30997@nuim.ie>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1511809330-1199007664=:31698"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57687 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbXL3Jnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 04:43:39 -0500
In-Reply-To: <20071230011500.GA30997@nuim.ie>
Content-ID: <Pine.LNX.4.64.0712301142151.31698@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1511809330-1199007664=:31698
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712301142152.31698@kivilampi-30.cs.helsinki.fi>

On Sun, 30 Dec 2007, Gavin McCullagh wrote:

> Hi,
> 
> On Fri, 21 Dec 2007, Ilpo Järvinen wrote:
> 
> > > I need to re-read properly, but I think the same problem affects the
> > > microsecond values where TCP_CONG_RTT_STAMP is set (used by vegas, veno,
> > > yeah, illinois).  I might follow up with another patch which changes the
> > > behaviour where TCP_CONG_RTT_STAMP when I'm more sure of that.
> >
> > Please do, you might have to remove fully_acked checks to do that right 
> > though so it won't be as straight-forward change as this one and requires 
> > some amount of thinking to result in a right thing.
> 
> The TCP_CONG_RTT_STAMP code does need to be fixed similarly.  A combined
> patch will follow this mail.  As I understand it, the fully_acked checks
> kick in where the ACK is a portion of a TSO chunk and doesn't completely
> ACK that chunk.  Leaving the checks in place means you get one rtt for each
> TSO chunk, based on the ACK for the last byte of the chunk.  This rtt
> therefore is the maximum available and includes the time-lag between the
> first and last chunk being acked.  Removing the tests gives you an RTT
> value for each ACK in a tso chunk, including the minimum and maximum.  It
> seems the minimum rtt is the best indicator of congestion.  On the other
> hand having all available RTTs gives the congestion avoidance greater
> knowledge of how the RTT is evolving (albeit somewhat coloured by TSO
> delays which don't seem too severe in my tests).

I guess the non-minimum TSO delays are only significant in case there was 
something unexpectional happening and in such case we definately want to 
have some measurements taken.


-- 
 i.
---696243703-1511809330-1199007664=:31698--
