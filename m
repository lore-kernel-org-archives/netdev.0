From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 1 Dec 2015 10:44:45 -0500
Message-ID: <20151201154445.GF29497@tuxdriver.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
 <20151129.222138.1582847465760563254.davem@davemloft.net>
 <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
 <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
 <CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>
 <CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@kernel.org>, David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56157 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbbLAPpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 10:45:15 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 09:26:51PM -0800, Tom Herbert wrote:
> On Mon, Nov 30, 2015 at 5:28 PM, Jesse Gross <jesse@kernel.org> wrote:

> > Based on what we can do today, I see only two real choices: do some
> > refactoring to clean up the stack a bit or remove the existing VXLAN
> > offloading altogether. I think this series is trying to do the former
> > and the result is that the stack is cleaner after than before. That
> > seems like a good thing.
> 
> There is a third choice which is to do nothing. Creating an
> infrastructure that claims to "Generalize udp based tunnel offload"
> but actually doesn't generalize the mechanism is nothing more than
> window dressing-- this does nothing to help with the VXLAN to
> VXLAN-GPE transition for instance. If geneve specific offload is
> really needed now then that can be should with another ndo function,
> or alternatively ntuple filter with a device specific action would at
> least get the stack out of needing to be concerned with that.
> Regardless, we will work optimize the rest of the stack for devices
> that implement protocol agnostic mechanisms.

Is there no concern about NDO proliferation? Does the size of the
netdev_ops structure matter? Beyond that, I can see how a single
entry point with an enum specifying the offload type isn't really any
different in the grand scheme of things than having multiple NDOs,
one per offload.

Given the need to live with existing hardware offloads, I would lean
toward a consolidated NDO. But if a different NDO per tunnel type is
preferred, I can be satisified with that.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
