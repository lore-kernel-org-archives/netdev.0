From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Thu, 26 Jun 2014 15:44:28 -0700 (PDT)
Message-ID: <20140626.154428.1099304313432511688.davem@davemloft.net>
References: <87lhskpizv.fsf@x220.int.ebiederm.org>
	<20140626.134335.2147671135749217539.davem@davemloft.net>
	<87egybibh5.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	stephen@networkplumber.org, cwang@twopensource.com,
	stefan.bader@canonical.com, stephane.graber@canonical.com,
	chris.j.arges@canonical.com, serge.hallyn@canonical.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbaFZWo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 18:44:29 -0400
In-Reply-To: <87egybibh5.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 26 Jun 2014 14:53:42 -0700

> The highlights of our earlier conversation.

Thanks for the context.

First of all it is clear that once you start creating containers on the
order of half the global neigh limit, yes you will run into problems as
it's easy to have 2 or more outputs in flight.

So it would perhaps be wise to scale the limits (in some way) based
upon the number of namespaces, but still keep it a global limit.

These entries consume a global resource (memory) and benefit from
global sharing, so I am still convinced that making the tables
themselves per-ns does not make any sense.

Secondly, if there are things holding onto neighbour entries for real
we should find this out.  Once could audit neigh_lookup*() invocations
to see where that might be happening.  Also neigh_create() calls with
'want_ref' set to true.

Finally, another problem are permanent neigh entries as those cannot
be reclaimed, that might be part of the main problem here.

One idea wrt. permanent entries is that we could decide that, since
they are administratively added, they don't count against the
thresholds and limits.
