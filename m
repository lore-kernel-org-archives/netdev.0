From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: orinoco driver causes *lots* of lockdep spew
Date: Thu, 03 Aug 2006 08:22:58 -0700
Message-ID: <44D214D2.70206@linux.intel.com>
References: <E1G8der-0001fm-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, davej@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, linville@tuxdriver.com, jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:11708 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S964783AbWHCPYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 11:24:09 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G8der-0001fm-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

Hi,

> Arjan van de Ven <arjan@infradead.org> wrote:
>> this is another one of those nasty buggers;
> 
> Good catch.  It's really time that we fix this properly rather than
> adding more kludges to the core code.

however I'm not quite yet convinced that this patch is going to solve
this particular deadlock.
(I agree with the principle of it and I think it's really needed,
I just don't yet see how it's going to solve this specific deadlock. But
then again it's early and I've not had sufficient coffee yet so I could
well be wrong)

> [WIRELESS]: Send wireless netlink events with a clean slate
> 
> Drivers expect to be able to call wireless_send_event in arbitrary
> contexts.  On the other hand, netlink really doesn't like being
> invoked in an IRQ context.  So we need to postpone the sending of
> netlink skb's to a tasklet.

it's not just about irq context, it's about being called with any lock that's
used in IRQ context; that is what makes this double nasty...

Greetings,
    Arjan van de Ven
