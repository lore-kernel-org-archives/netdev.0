From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Tue, 07 Aug 2007 17:59:20 -0700 (PDT)
Message-ID: <20070807.175920.15265201.davem@davemloft.net>
References: <20070805.232423.21363072.davem@davemloft.net>
	<1186491155.5163.68.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, rusty@rustcorp.com.au
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45119
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933289AbXHHA7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 20:59:20 -0400
In-Reply-To: <1186491155.5163.68.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 07 Aug 2007 08:52:35 -0400

> That doc is out of date on the split of work - it focusses mostly
> describing the original tulip which did not mix rx and tx in the
> napi_poll(). AFAIK, no driver does that today (although i really liked
> that scheme, there is a lot of fscked hardware out there that wont work
> well with that scheme). Where are the firemen when you need them? 

I am tempted to suggest we toss the document completely, for
two reasons:

1) It's geared towards conversions, whereas %99.9999 of the conversions
   that will ever happen, have happened.  Every single potential reader
   of this document is therefore writing new drivers with NAPI from the
   beginning.

2) Inaccurate documentation is often worse than no documentation.

It's not a bad thing to delete the document, and also we have a lot
of time until 2.6.24 finalizes with these changes and in that time
someone with the right incentive could write a fresh new NAPI
manual that represents reality.  Such a document could be added after
the merge window closes.

This also reminds me that we confuse people by having two driver
models for interrupt handling.  I've been reluctant to remove the
"optional" component of NAPI especially when it didn't handle
multi-queue properly (which basically made drivers for virtualized
devices impossible without using dummy devices for each queue).
But that is no longer true and there isn't any reason for a new
driver not to be NAPI from the beginning.
