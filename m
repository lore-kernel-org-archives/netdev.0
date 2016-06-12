From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] fib_rules: don't break ECN with TOS rules
Date: Sun, 12 Jun 2016 02:38:20 +0200
Message-ID: <1465691900.3002733.634955425.22770D5E@webmail.messagingengine.com>
References: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org>
 <alpine.LFD.2.11.1606120230560.2087@ja.home.ssi.bg>
 <1465691799.3002631.634954313.3E40DB3C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33574 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751823AbcFLAiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 20:38:21 -0400
In-Reply-To: <1465691799.3002631.634954313.3E40DB3C@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016, at 02:36, Hannes Frederic Sowa wrote:
> On Sun, Jun 12, 2016, at 02:09, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Sat, 11 Jun 2016, Hannes Frederic Sowa wrote:
> > 
> > > Users of ToS rules could accidentally break ECN, this patch tries to
> > > fix this in a way so we don't break shell scripts depending on the old
> > > behavior while still being transparent to ECN. This quietly fixes ECN
> > > behavior for old setups.
> > > 
> > > For IPv6 we have no check if we check for ECN bits, in IPv4 we only
> > > check for the last bit, which is specified to be '0' from pre-DSCP times
> > > (because of implementation confusion).
> > > 
> > > This patch changes fib rules in a way that matches only for ecn bits
> > > will never match from now on (I consider them illegal), as we simply
> > > ignore those rules (it was easier to explain in a pr_warn). Opinions?
> > 
> > 	Well, may be the confusion comes from commit 89aef8921bfb
> > ("ipv4: Delete routing cache.") where the 'tos &= IPTOS_RT_MASK;'
> > line is lost from ip_route_input_common. I think, we should
> > add it back, so that we can properly match input routes with rules
> > that specify tos value. Old kernels didn't stored ECN bits in
> > flowi4_tos in the input path, so we should do the same.
> 
> I would love to have done that but was fearing problems with user space
> compatibility. Also IPTOS_RT_MASK is not enough for filtering, we need
> to check for the whole INET_ECN_MASK.

Correction: IPTOS_RT_MASK would be fine, but fib4_rule_configure uses
IPTOS_TOS_MASK.

Bye,
Hannes
