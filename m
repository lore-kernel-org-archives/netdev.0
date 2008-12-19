From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Sat, 20 Dec 2008 01:04:52 +0300
Message-ID: <20081219220452.GB704@ioremap.net>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <494C0255.8010208@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Bolkhovitin <vst@vlnb.net>, linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:47068 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752048AbYLSWEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 17:04:53 -0500
Content-Disposition: inline
In-Reply-To: <494C0255.8010208@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2008 at 12:21:41PM -0800, Jeremy Fitzhardinge (jeremy@goop.org) wrote:
> I think Rusty has a patch to put some kind of put notifier in struct 
> skb_shared_info, but I'm not sure of the details.

Yes, he added destructor callback into shared info.

There maybe a problem though, if iscsi will run over xen network, but in
this case xen may copy the data, or iscsi may do that after determining
that underlying network device does not allow shared info destructor
(vis device/route flag for example).

> Wouldn't you only need to do the lookup on the last put?
> 
> An external lookup table might well for for us, if the net_put_page() 
> change is acceptable to the network folk.

That sounds like the best solution for this problem.
David, will you accept shared info destructor?
And second fraglist? (Put to the new line to easily say no here :)

-- 
	Evgeniy Polyakov
