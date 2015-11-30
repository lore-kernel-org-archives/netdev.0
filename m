From: Florian Westphal <fw@strlen.de>
Subject: Re: Increasing skb->mark size
Date: Mon, 30 Nov 2015 03:24:59 +0100
Message-ID: <20151130022459.GC29878@breakpoint.cc>
References: <1448397144.14854.27.camel@mattb-dl>
 <20151124203602.GB23215@breakpoint.cc>
 <1448398614.14854.39.camel@mattb-dl>
 <20151130020816.GB29878@breakpoint.cc>
 <CAKD1Yr2vWpKsibNY6ShYZiKLMFSD_2gxRVa=DyXx5jkEs25AZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42425 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751575AbbK3CZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 21:25:03 -0500
Content-Disposition: inline
In-Reply-To: <CAKD1Yr2vWpKsibNY6ShYZiKLMFSD_2gxRVa=DyXx5jkEs25AZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo Colitti <lorenzo@google.com> wrote:
> On Mon, Nov 30, 2015 at 11:08 AM, Florian Westphal <fw@strlen.de> wrote:
> > We have ctnetlink which allows direct setting of ctmark/ctlabels.
> 
> Can those labels be set early enough in the stack to affect the source
> address chosen for outgoing connections?

No, same restrictions as connmarks or skb marks apply.

Furthermore, since its stored in the conntrack area, the conntrack isn't
created until after the first packet hits NF output hook, and its not
visible until after POSTROUTING hook.

There was an out of tree patch to allow to use ipsets to select
source addresses instead of mark+fwmark:

https://lkml.org/lkml/2012/12/3/93

I think thats something we shouldn't really go for this.

However, if fwmark is too limiting (and given these hacks exist),
maybe we should start thinking for alternatives?
