From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: >10% performance degradation since 2.6.18
Date: Mon, 6 Jul 2009 12:53:53 -0600
Message-ID: <20090706185353.GY5480@parisc-linux.org>
References: <20090705040137.GA7747@gondor.apana.org.au> <4A522D9A.1090006@hp.com> <BC02C49EEB98354DBA7F5DD76F2A9E800357D5A0C5@azsmsx501.amr.corp.intel.com> <20090706174203.GV5480@parisc-linux.org> <BC02C49EEB98354DBA7F5DD76F2A9E800357E11BC8@azsmsx501.amr.corp.intel.com> <20090706180530.GX5480@parisc-linux.org> <BC02C49EEB98354DBA7F5DD76F2A9E800357E11D67@azsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jeff Garzik <jeff@garzik.org>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"arjan@infradead.org" <arjan@infradead.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Styner, Douglas W" <douglas.w.styner@intel.com>,
	"Prickett, Terry O" <terry.o.prickett@intel.com>,
	"Wilcox, Matthew R" <matthew.r.wilcox@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Ma, Chinang" <chinang.ma@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:33908 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbZGFSxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 14:53:52 -0400
Content-Disposition: inline
In-Reply-To: <BC02C49EEB98354DBA7F5DD76F2A9E800357E11D67@azsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 11:48:47AM -0700, Ma, Chinang wrote:
> On the distributing interrupt load subject.  Can we do the same thing with the IOC interrupts. We have 4 LSI 3801, The number of i/o interrupt is huge on 4 of the cpus. Is there a way to divide the IOC irq number so we can spread out the i/o interrupt to more cpu?

I think the LSI 3801 only has one interrupt per ioc, but they could
perhaps be better spread-out.  Right now, they're delivering interrupts
to CPUs 2, 3, 4 and 5.  Possibly spreading them out to CPUs 2, 6, 10
and 14 would help.  Or maybe it would hurt ...

(nb: the ioc interrupts are similarly tied to CPUs 2, 3, 4 and 5 with
2.6.18, so this isn't a likely cause of/solution to the regression,
it may just be a path to better numbers).

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
