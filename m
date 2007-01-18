From: Brandon Craig Rhodes <brandon@rhodesmill.org>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Thu, 18 Jan 2007 08:55:37 -0500
Message-ID: <87hcuo30di.fsf@ten22.rhodesmill.org>
References: <87bqky759v.fsf@ten22.rhodesmill.org>
	<87mz4h61p0.fsf@ten22.rhodesmill.org>
	<20070118131631.GA24622@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-23-211-138.clients.speedfactory.net ([66.23.211.138]:54365
	"EHLO ten22.rhodesmill.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932333AbXARNzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 08:55:38 -0500
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20070118131631.GA24622@ee.oulu.fi> (Pekka Pietikainen's message
	of "Thu, 18 Jan 2007 15:16:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Pietikainen <pp@ee.oulu.fi> writes:

> On Wed, Jan 17, 2007 at 11:46:35AM -0500, Brandon Craig Rhodes wrote:
>> Having further reviewed my code, I have changed my mind; the
>> ieee80211_crypt_tkip routines are not designed to be responsible for
>> creating enough headroom and tailroom.
>
> Even then, if ieee80211_tkip_encrypt() didn't produce debug output
> for the not enough space-case, should that be added to catch other
> potentially broken drivers?

I think your idea is an excellent one, and would have prevented my
having to add a half-dozen printk()'s to the code myself to discover
what was going on!

I would be happy to submit such a patch myself, but am not sure what
the local kernel conventions are regarding error messages - and the
ieee80211_crypt_tkip.c functions seem wildly inconsistent with regard
to debugging messages!  In some circumstances, debug messages are
always produced; in several others, net_ratelimit() is called to
decided whether to print an error (but why in these cases and not
others?); and in many cases, nothing is printed at all (is this
because convention would dictate that the caller discover the error
and print something out?).

If I want to generate a patch that festoons the ieee80211 functions
with informative error messages, what are the guidelines?

-- 
Brandon Craig Rhodes   brandon@rhodesmill.org   http://rhodesmill.org/brandon
