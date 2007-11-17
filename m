From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Fri, 16 Nov 2007 18:59:30 -0600
Message-ID: <cccedfc60711161659s73477594lb0ff57b9bcbd7f24@mail.gmail.com>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	 <20071115082600.GA2366@ff.dom.local>
	 <20071115102005.0cf46f9a@freepuppy.rosehill> <473CD1F6.9030709@o2.pl>
	 <cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
	 <20071115203508.4ad025f2@freepuppy.rosehill>
	 <cccedfc60711160821p5f1790eaq8d385e71726cd5a0@mail.gmail.com>
	 <20071116084706.467aa834@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:36748 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbXKQA7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 19:59:32 -0500
Received: by nf-out-0910.google.com with SMTP id g13so983984nfb
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 16:59:31 -0800 (PST)
In-Reply-To: <20071116084706.467aa834@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/16/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Fri, 16 Nov 2007 10:21:25 -0600
> "Jon Nelson" <jnelson@jamponi.net> wrote:
>
> > I get a segmentation fault.
> >
> > Should this patch be in addition to the one from bug 9382?
> > http://bugzilla.kernel.org/attachment.cgi?id=13555&action=view
> >
> Yes. The new patch adds just recomputes the rx buf size in
> one place, so it can be set when device is down.
> Also, the computation will always yield same result now, the old
> code computed different values depending on whether it was initial
> or changed MTU.

OK. This is what I did.
Using git I grabbed a copy of Linus' tree and using the latest files
for via-velocity.[c,h], commit
99fee6d7e5748d96884667a4628118f7fc130ea0, I determined that if I
backed out change 44c10138fd4bbc4b6d6bff0873c24902f2a9da65 (PCI:
Change all drivers to use pci_device->revision) I could get it to
compile. This gets me a more recent driver.

Then I applied both of the patches you have provided me, and built and
tried that.
No sigseg, no oops on initial MTU, no sigseg or oops on subsequent MTU changes.

Performance appears to be worse after MTU changes, though. I can get
about 30MB/s with 7200 (the largest the board will support?) and about
5MB/s with 1500. If I *start out* with 1500 performance is 35-40MB/s.
However, the immediate issue appears to be solved (oopses).

If there is a better tree to pull from, I'm more than willing to keep
trying different drivers, at least for a while. I also have tg3 driver
issues to sort out.

-- 
Jon
