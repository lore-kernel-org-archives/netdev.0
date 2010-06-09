From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location
	representation
Date: Wed, 9 Jun 2010 11:13:17 -0700
Message-ID: <20100609181317.GB19804@dvomlehn-lnx2.corp.sa.net>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net> <874ohc65es.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:25091 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758078Ab0FISNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 14:13:17 -0400
Content-Disposition: inline
In-Reply-To: <874ohc65es.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 02:17:47AM -0500, Andi Kleen wrote:
> David VomLehn <dvomlehn@cisco.com> writes:
> 
> First your mailer generates broken cc addresses like
> "netdev@vger.kernel.org"@cisco.com
> 
> > This patch allows the location of a call to be recorded as a small integer,
> > with each call location ("callsite") assigned a new value the first time
> > the code in that location is executed. Locations can be recorded as a
> > an address or as a __FILE__/__LINE__ pair. The later is easier to read, but
> > requires significantly more space.
> 
> Seems overly complicated.
> 
> How about using a hash of __FILE__, __LINE__ instead? 
> With some care you can write it in a way that it gets completely
> evaluated by gcc at compile time, so it's just a constant then.
> 
> That may use a few more bits then, but that's far better
> than having so much runtime overhead for this.

The same indexing scheme is employed whether it is configured for reporting
an address or the __FILE__/__LINE__ pair. The __FILE__/__LINE__ data is
stored statically at compile time, but since the __FILE__ values are strings
and may be pretty long, it can use a significant amount of space in the
string table. Performance wise, the key difference is that reporting an
address means that, the first time you go through a callsite, it stores
the return address. This doesn't need to be repeated during subsequent
calls, so the performance difference is miniscule.
-- 
David VL
