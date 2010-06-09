From: Florian Mickler <florian@mickler.org>
Subject: Re: [RFC PATCH 1/2] mac80211: make max_network_latency notifier
 atomic safe
Date: Wed, 9 Jun 2010 12:20:50 +0200
Message-ID: <20100609122050.1dd18132@schatten.dmk.lab>
References: <1276074915-26879-1-git-send-email-florian@mickler.org>
	<1276076287.3727.15.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pm list <linux-pm@lists.linux-foundation.org>,
	james.bottomley@suse.de, markgross@thegnar.org,
	mgross@linux.intel.com,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Javier Cardona <javier@cozybit.com>, Jouni Malinen <j@w1.fi>,
	Rui Paulo <rpaulo@gmail.com>,
	Kalle Valo <kalle.valo@nokia.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ist.d-labs.de ([213.239.218.44]:42937 "EHLO mx01.d-labs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218Ab0FIKVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 06:21:09 -0400
In-Reply-To: <1276076287.3727.15.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Jun 2010 11:38:07 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Wed, 2010-06-09 at 11:15 +0200, florian@mickler.org wrote:
> > In order to have the pm_qos framework be callable from interrupt
> > context, all listeners have to also be callable in that context.
> 
> That makes no sense at all. Why add work structs _everywhere_ in the
> callees and make the API harder to use and easy to get wrong completely,
> instead of just adding a single work struct that will be queued from the
> caller and dealing with the locking complexity etc. just once.
> 
> johannes

Just to defend this approach, but I'm certainly not married to it
(hence RFC):

There are only two listeners at the moment. I suspect that most future
uses of the framework need to be atomic, as the driver that
requests a specific quality of service probably doesn't want to get into
races with the provider of that service(listener). So i suspected the
network listener to be the special case.  

The race between service-provider and qos-requester for non-atomic
contextes is already there, isn't it? so, locking complexity shouldn't
be worse than before.

But my first approach to this is seen here:
https://lists.linux-foundation.org/pipermail/linux-pm/2010-June/026902.html

A third possibility would be to make it dependent on the
type of the constraint, if blocking notifiers are allowed or not. 
But that would sacrifice API consistency (update_request for one
constraint is allowed to be called in interrupt context and
update_request for another would be not).

Cheers,
Flo
