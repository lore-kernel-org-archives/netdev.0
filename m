From: Dan Williams <dcbw@redhat.com>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 13:12:51 -0500
Message-ID: <1166638371.2798.26.camel@localhost.localdomain>
References: <20061219185223.GA13256@srcf.ucam.org>
	 <200612191959.43019.david-b@pacbell.net>
	 <20061220042648.GA19814@srcf.ucam.org>
	 <200612192114.49920.david-b@pacbell.net> <20061220053417.GA29877@suse.de>
	 <20061220055209.GA20483@srcf.ucam.org>
	 <1166601025.3365.1345.camel@laptopd505.fenrus.org>
	 <20061220125314.GA24188@srcf.ucam.org>
	 <20061220150009.1d697f15@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matthew Garrett <mjg59@srcf.ucam.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030227AbWLTSLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 13:11:20 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061220150009.1d697f15@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-20 at 15:00 +0100, Jiri Benc wrote:
> On Wed, 20 Dec 2006 12:53:14 +0000, Matthew Garrett wrote:
> > The situation is more complicated for wireless. Userspace expects to be 
> > able to get scan results from the card even if the interface is down.
> 
> User space should get an error when trying to get scan results from the
> interface that is down. Some drivers are broken and don't do this but
> when they're fixed there is no problem here.

Entirely correct.  If the card is DOWN, the radio should be off (both TX
& RX) and it should be in max power save mode.  If userspace expects to
be able to get the card to do _anything_ when it's down, that's just
110% wrong.  You can't get link events for many wired cards when they
are down, so I fail to see where userspace could expect to do anything
with a wireless card when it's down too.

> > In that case, I'm pretty sure we need a third state rather than just
> > "up" or "down".
> 
> We have that third state, it's IFF_DORMANT. Not supported yet by any
> wireless driver/stack, unfortunately.

So we have 3 states?  What purpose does DORMANT serve and what is
allowed in DORMANT?

Also, how does rfkill fit into this?  rfkill implies killing TX, but do
we have the granularity to still receive while the transmit paths are
powered down?

Dan

> Thanks,
> 
>  Jiri
> 

