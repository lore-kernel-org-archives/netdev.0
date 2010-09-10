From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [patch] ixgbevf: potential NULL dereference on allocation
 failure
Date: Fri, 10 Sep 2010 13:25:11 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F65FF46E@orsmsx508.amr.corp.intel.com>
References: <20100910115234.GB5959@bicker>
 <20100910.132137.212394088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"error27@gmail.com" <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24563 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059Ab0IJUZP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 16:25:15 -0400
In-Reply-To: <20100910.132137.212394088.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, September 10, 2010 1:22 PM
>To: error27@gmail.com
>Cc: Rose, Gregory V; Kirsher, Jeffrey T; netdev@vger.kernel.org; kernel-
>janitors@vger.kernel.org
>Subject: Re: [patch] ixgbevf: potential NULL dereference on allocation
>failure
>
>It's trying to optimize out the "down/up" of the device, which needs
>to be done if we allocated a new TX ring.
>
>It also adjusts the semantics of the error return,  in that if the
>TX ring re-sizing went OK but the RX resizing failed, it returns
>success.
>
>That's kind of crummy semantics, if any part fails we should unwind
>and return an error.  So just do the necessary memory allocations
>first, and don't make any changes unless they all succeed.
>
>This code also seems to be incredibly racy.  It allocates the new RING
>structure, and copies the existing entries over.  Meanwhile the chip
>is still running and we're potentially processing these same ring
>entries, so by the time we actually assign adapter->{rx,tx}_ring
>pointers the contents could have changed.
>
>Probably the simplest thing to do is to structure this such that the
>chip is quiesced around the entire ring set operation, so something
>like:

[snip]

I'll take this up and see what I can do to fix it up a bit and address your concerns.  Thanks for the suggestions.

- Greg

