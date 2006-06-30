From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 28 of 39] IB/ipath - Fixes a bug where our delay for EEPROM no longer works due to compiler reordering
Date: Fri, 30 Jun 2006 14:08:19 -0700
Message-ID: <adar716e4ho.fsf@cisco.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
	<5f3c0b2d446d78e3327f.1151617279@eng-12.pathscale.com>
	<20060629170711.757a97d2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bryan O'Sullivan" <bos@pathscale.com>, mst@mellanox.co.il,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:4631 "EHLO
	sj-iport-1.cisco.com") by vger.kernel.org with ESMTP
	id S932420AbWF3VIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:08:21 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060629170711.757a97d2.akpm@osdl.org> (Andrew Morton's message of "Thu, 29 Jun 2006 17:07:11 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > >  static void i2c_wait_for_writes(struct ipath_devdata *dd)
 > >  {
 > > +	mb();
 > >  	(void)ipath_read_kreg32(dd, dd->ipath_kregs->kr_scratch);
 > >  }

 > That's a bit weird.  I wouldn't have expected the compiler to muck around
 > with a readl().

I never liked this patch.  The last time it came up there were
conflicting answers about whether it was a code generation bug or a
real issue talking to hardware or what.  At the least I think this
merits a big comment explain what's going on -- and even better would
be really understanding the bug that's being fixed so that we're
confident it is indeed a real fix.

 - R.
