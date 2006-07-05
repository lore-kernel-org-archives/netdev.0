From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.17-mm6
Date: Wed, 5 Jul 2006 13:13:50 +0200
Message-ID: <20060705111350.GA25161@elte.hu>
References: <20060703030355.420c7155.akpm@osdl.org> <200607042153.31848.rjw@sisk.pl> <1152043271.3109.95.camel@laptopd505.fenrus.org> <44AB940F.7000801@s5r6.in-berlin.de> <44AB9633.9090208@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964813AbWGELSd@vger.kernel.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Content-Disposition: inline
In-Reply-To: <44AB9633.9090208@s5r6.in-berlin.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:

> I wrote:
> > (Ieee1394 core's usage of the skb_* API is entirely unrelated to
> > networking; even if eth1394 was used.)
> 
> PS:
> I wonder if it wouldn't be better to migrate ieee1394 core away from 
> skb_*. I didn't look thoroughly at it yet but the benefit of using 
> this API appears quite low to me.

yeah, it seems to be the wrong abstraction to use. It's also more 
expensive than necessary: e.g. skb-heads have a qlen field that is 
maintained in every list op - but the ieee1394 code does not make use of 
the queue-length information. Using list.h plus a spinlock should do the 
trick?

	Ingo
