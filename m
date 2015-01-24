From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 13:34:59 +0000
Message-ID: <20150124133459.GA27523@casper.infradead.org>
References: <20150123174609.GA23242@casper.infradead.org>
 <54C39C8E.4@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52588 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbbAXNfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 08:35:06 -0500
Content-Disposition: inline
In-Reply-To: <54C39C8E.4@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/15 at 08:22am, Jamal Hadi Salim wrote:
> It is up to user space to decide on what the policy should do.
> The kernel is not paid to think. You tell it what to do and it does it
> efficiently. So if you are going to tell it to have a mix and match
> of some things to execute in hardware and some in software then
> it may shoot someone's big toe.

OK. We seem agree on this part. In order to do so, user space needs
to know about hardware capabilities. If that should happen through
tc, so be it. John raised some open question around this and the
rtnl lock is currently a blocker on this architecture as well.

> IOW, user space should decide how a packet is going to flow.
> Agreed that we would need a good way to provide this knowledge
> to user space.
> BTW: Thomas, reading your other email quickly:
> the idea that metadata would be carried around on OF pipeline and
> some script at the end executes the actions is imo  a hardware
> pipeline hack limitation. Why do i want to defer dropping a packet
> when some action is telling me to drop it? ;->

There is obviously no reason to defer a drop.

An example of deferred actions would be if only certain tables allow
certain actions but the matching to chose the action is done in a 
previous tables. Or if you have multiple tables matching on the
original packet header and you need to defer the L2/L3 rewrite until
all matching and action construction is done.

> For some reason, brcm hardware in particulat requires that i
> complete the pipeline first.
> I dont know why we need such a limitation in s/ware (and tc will kill
> the pipeline when needed).

Not sure what "killing the pipeline" means ;-)
