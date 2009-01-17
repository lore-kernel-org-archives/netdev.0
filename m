From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ixgbe: Replace LRO with GRO
Date: Sat, 17 Jan 2009 20:52:56 +1100
Message-ID: <20090117095256.GA26169@gondor.apana.org.au>
References: <20090113092625.GA28015@gondor.apana.org.au> <20090113092828.GA28052@gondor.apana.org.au> <20090114084412.GA17393@gondor.apana.org.au> <20090115034619.GA28267@gondor.apana.org.au> <9929d2390901161532j57528215mdb01f38be1bd4c7f@mail.gmail.com> <20090117003629.GA22370@gondor.apana.org.au> <EA929A9653AAE14F841771FB1DE5A1365F59F11911@rrsmsx501.amr.corp.intel.com> <20090117034510.GA23714@gondor.apana.org.au> <EA929A9653AAE14F841771FB1DE5A1365F59F11A11@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53174 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754247AbZAQJxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 04:53:05 -0500
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F59F11A11@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 17, 2009 at 01:07:46AM -0700, Tantilov, Emil S wrote:
>
> The test is done by a script that:
> 
> 1. checks the connection to the secondary system (ping)
> 2. copies the test file to the secondary test system (put)
> 3. copies the same file again from the secondary to the test system (get)
> 4. Compares the checksum of the sent vs. the received file
> 
> Since I had tcpdump on both ends - I think you should see both session in each. The file I named sender (probably a bit incorrect) is just the capture taken from the primary test system (the one that started the script). This is also the system on which I have the latest git with GRO.

Thanks, that makes a lot more sense.  Just to confirm, the second
part of the sender dump should be the one showing GRO, right?

> > However, it is not very clear what is causing this loss.  BTW,
> > did you apply the fix b0059b50b70dc3a908bea4ece2f9494a22200018
> > (gro: Fix page ref count for skbs freed normally) on both sides?
> > That one is required to make igb or ixgbe work properly.
> Ah - doesn't seem like I have this fix. Jeff will have to pull this in our test tree.

OK, although this bug should only manifest itself if aggregation
occurs, which apparently isn't the case according to the dump.

> > Another thing to try is to disable GSO/TSO on both sides as that
> > is complicating the interpretation of the dumps.
> Will do if the fix above doesn't help.

BTW, when you're testing without GRO are you disabling GRO with
ethtool or loading an ixgbe driver without the patch? If the latter
please try it with ethtool (even if you don't have a patched ethtool
that supports GRO you can always disable RX checksums).

Maybe I just stuffed up the ixgbe patch.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
