From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location representation
Date: Wed, 09 Jun 2010 09:17:47 +0200
Message-ID: <874ohc65es.fsf@basil.nowhere.org>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52645 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab0FIHRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 03:17:49 -0400
In-Reply-To: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net> (David VomLehn's message of "Mon\, 7 Jun 2010 17\:30\:52 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David VomLehn <dvomlehn@cisco.com> writes:

First your mailer generates broken cc addresses like
"netdev@vger.kernel.org"@cisco.com

> This patch allows the location of a call to be recorded as a small integer,
> with each call location ("callsite") assigned a new value the first time
> the code in that location is executed. Locations can be recorded as a
> an address or as a __FILE__/__LINE__ pair. The later is easier to read, but
> requires significantly more space.

Seems overly complicated.

How about using a hash of __FILE__, __LINE__ instead? 
With some care you can write it in a way that it gets completely
evaluated by gcc at compile time, so it's just a constant then.

That may use a few more bits then, but that's far better
than having so much runtime overhead for this.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
