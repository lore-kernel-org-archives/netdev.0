From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]: Fix a warning in the niu driver
Date: Wed, 14 Jul 2010 11:28:00 -0700 (PDT)
Message-ID: <20100714.112800.189702548.davem@davemloft.net>
References: <4C3514ED.2060904@redhat.com>
	<20100707.170820.146356362.davem@davemloft.net>
	<4C3DB927.2060106@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754886Ab0GNS1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 14:27:45 -0400
In-Reply-To: <4C3DB927.2060106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 14 Jul 2010 09:18:31 -0400

> Dave, would it be acceptable if I then wrapped link in
> uninitialized_var() to get rid of the warning I'm trying to resolve?  It
> seems that your patch then checks for a valid page value so it should be
> okay.

If the patch I posted doesn't fix your warning, the compiler is broken.

Any code path that would not initialize the variable, hits the BUG()
therefore making return from the function completely unreachable,
therefore the uses of the initialized variable are completely unreachable.

I'm not adding workarounds for compiler warning bugs.  They aren't real
bugs, and such efforts tend to _add_ bugs to the tree rather than fix
real problems.
