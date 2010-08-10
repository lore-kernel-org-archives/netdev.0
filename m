From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH v2]  net: add Fast Ethernet driver for PXA168.
Date: Tue, 10 Aug 2010 19:30:52 +0200
Message-ID: <20100810173052.GB25474@mail.wantstofly.org>
References: <EC64E4604C8024438259B683BB2514E1082B1CB1B0@SC-VEXCH1.marvell.com> <FE9BFA4C-11AB-46B9-A514-EB62467A1BB7@marvell.com> <1281429004.17990.2.camel@pe-lt522.marvell.com> <20100810123329.GR8876@mail.wantstofly.org> <7B1965FC-E61F-4BFD-86B1-F9D390A012CC@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sachin Sanap <ssanap@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Prabhanjan Sarnaik <sarnaik@marvell.com>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	Mark Brown <markb@marvell.com>
To: Philip Rakity <prakity@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:35936 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446Ab0HJRay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 13:30:54 -0400
Content-Disposition: inline
In-Reply-To: <7B1965FC-E61F-4BFD-86B1-F9D390A012CC@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 09:24:23AM -0700, Philip Rakity wrote:

> >> * Headroom in SKB for 802.11 not included in the patch since that
> >>  varies based on 802.11 a/b/g/n.
> > 
> > I don't think this is true?
> > 
> > (The 11a/b/n on-the-air preambles are of different lengths (and are
> > sent at different rates), but that isn't visible to software.)
> 
> 802.11b/g headers are larger and if not handled by firmware in an
> offload engine are programmed by the driver.  There needs to be room
> for 
> 
> a) Frame Control (2 bytes)
> b) AID (2 bytes)
> c) address-1 (6 bytes)
> d) address-2 (6 bytes)
> e) address-3 (6 bytes)
> f) seqfrag  (2 bytes)
> g) address-4 (6 bytes) 
> 
> or 30 bytes.

Depends on the driver and/or whether you are doing WDS.

mwl8k always needs 30 bytes due to hardware pecularities (while the
4-address-with-QoS header is 32 bytes, the QoS field is always passed
in the TX descriptor), but other drivers might need 32 bytes (and not
30 bytes) for 4-address-with-QoS headers, or might not need 30 or 32
bytes for transmitting 3-address or 2-address frames.


> 11n needs more.

Really?  Pointer?


> Some of these fields ARE visible to s/w.

Where did I say that they are not?

What I said was that the _preambles_ are not visible to software.
