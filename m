From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Integration of Open vSwitch
Date: Wed, 30 Nov 2011 15:00:11 +0800
Message-ID: <20111130070011.GA32630@gondor.apana.org.au>
References: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, netdev <netdev@vger.kernel.org>,
	dev@openvswitch.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Chris Wright <chrisw@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41426 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab1K3HAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 02:00:25 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 10:25:34PM -0800, Jesse Gross wrote:
> Hi Herbert and Jamal (and everyone else),
> 
> Sorry about starting yet another thread but the other one went in so
> many directions that I think a lot of things got lost in it.  As I
> mentioned before, I'd like to have a bit of a design discussion of
> what it would look like if Open vSwitch were to use some of the
> existing components (and really focus on just that).  There were a
> number of suggestions made about using parts of the bridge, tc,
> netfilter, etc. and some of them overlap or conflict so I don't quite
> have a coherent solution in mind.  Would you guys mind walking through
> what each of you envision it looking like?

Personally I think your patches are fine as is.

It would obviously be nice if we could refactor the code as Jamal
suggested into classifiers/actions, which would allow us to reuse
them elsewhere, e.g., the flow cache classifier could be merged
with the GRO mechanism, or something even grander like the unified
flow cache, while the using standard actions would make all
existing actions available and generalise OVS into something
that allows you to direct traffic at will to any destination
in a system, without having to have a data-path object at all.

But really I don't see immediate gains that are big enough to
warrant any actions in that direction right now.  If we really
wanted to do that in future we can always add those classifiers
and actions and migrate things over.

The other factor I considered is scalability.  The OVS code as is
is not really friendly to SMP/NUMA scalability (but as Eric pointed,
neither is the classifier/action layer).  However, if this were to
become a problem in future I'm sure we could extend either the
interface as is (e.g., deploying multiqueue netlink sockets), or
migrate to something else.

So I don't really have any objections to this going into the tree.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
