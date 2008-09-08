From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours: ip6_dst_lookup_tail NULL crash
Date: Tue, 9 Sep 2008 00:34:18 +0400
Message-ID: <20080908203418.GA16637@2ka.mipt.ru>
References: <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080907181109.GA2466@2ka.mipt.ru> <200809072119.50307.rdenis@simphalempin.com> <20080908.131547.26037628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdenis@simphalempin.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:37732 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216AbYIHUgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 16:36:05 -0400
Content-Disposition: inline
In-Reply-To: <20080908.131547.26037628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David.

On Mon, Sep 08, 2008 at 01:15:47PM -0700, David Miller (davem@davemloft.net) wrote:
> But I don't like this patch for several reasons:
> 
> 1) Slapping on a NULL check in response to a OOPS at that exact
>    location is usually a very big red flag, and deserves high scrutiny
>    instead of blind acceptance.
> 
> 2) Looking at the indentation of this DAD code block (it's all one tab
>    too much) it's obviously a very shitty cut and paste job.  If the
>    coding style was too difficult to get right, what does this say
>    about that change that brought the code here, semantically? :-/
> 
>    This means we should figure out how this code got to this place,
>    and what kind of invariants existed at the old location that might
>    make this dst->neighbour dereference valid, and what implications
>    there are for the fact that it can now be NULL.
> 
> Really, we really need to understand much more deeply this situation.

Well, yes. The whole 'optimistic' dad looks a bit suspicious. I think
failed dst entry without neighbour is a result of the 'static' dst entry
returned by the above route lookup and previously neighbour was not
used at all. This patch fixes the opps, but may be just hiding a
problem, but reading how this optimistic duplicate address detection
works, I see no strict requirements that returned route entry has to
have neighbour, so this check actually can be a right fix.

I've added Neil Horman, who created the patch 1.5 years ago, to the
copy list.

-- 
	Evgeniy Polyakov
