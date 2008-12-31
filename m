From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.27.8 (+the idr fix) TCP Ack issue
Date: Wed, 31 Dec 2008 22:20:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812312215590.3247@wrl-59.cs.helsinki.fi>
References: <20081230195858.GA23530@flint.arm.linux.org.uk>
 <Pine.LNX.4.64.0812311200570.3120@wrl-59.cs.helsinki.fi>
 <20081231171016.GA1901@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-579233435-1230754846=:3247"
Cc: Netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40756 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756485AbYLaUUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 15:20:48 -0500
In-Reply-To: <20081231171016.GA1901@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-579233435-1230754846=:3247
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 31 Dec 2008, Russell King wrote:

> On Wed, Dec 31, 2008 at 12:38:24PM +0200, Ilpo Järvinen wrote:
> > If you have the dump still at handy, could you add couple of -v -v for
> > tcpdump. It could be that the peer is using bogus seqnos in the
> > duplicate ACK but by default that's not visible for zero sized segs
> > (checked in tcp_validate_incoming in the 2.6.28.7 kernel).
> 
> Is "seqno" another name for the IP ID field?

No, it's a sequence number, there are two sequence number spaces per flow, 
one for each direction (each has a corresponding field in the tcp header). 
For pure ACKs tcpdump won't show the sequence number by default even 
though it's still there...

With tcpdump -n -v -v I get this for pure acks:

...: ., cksum 0x43c0 (correct), 671:671(0) ack 14649 win 36500

That 671:671(0) won't be visible with smaller verbosity.

-- 
 i.
---696208474-579233435-1230754846=:3247--
