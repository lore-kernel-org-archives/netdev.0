From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] net: introduce generic net_random_N helper
Date: Tue, 03 Sep 2013 05:41:57 -0700
Message-ID: <1378212117.2048.29.camel@joe-AO722>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
	 <1378204010-27050-2-git-send-email-dborkman@redhat.com>
	 <1378206045.2048.9.camel@joe-AO722> <5225CAB1.7080402@redhat.com>
	 <1378210546.2048.20.camel@joe-AO722> <5225D583.9090404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60590 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754762Ab3ICMl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 08:41:59 -0400
In-Reply-To: <5225D583.9090404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 14:26 +0200, Daniel Borkmann wrote:
> On 09/03/2013 02:15 PM, Joe Perches wrote:
> > I think #define net_random() prandom_u32()
> > should be removed eventually as well.
> 
> Why? Assume there could be different PRNGs in future that have different properties
> (e.g. speed vs. period, etc). Then, changing net_random() to something else is way
> easier and less error-prone than searching through the whole subtree of net and
> replacing every occurrence of prandom_u32().

Maybe.  There are already instances of prandom_u32
in the net tree.  I don't find value in the indirection.

Akinobu Mita once posted a s/net_random/prandom_u32/
patch: https://lkml.org/lkml/2012/12/23/140

> > If gcc doesn't already do this optimization,
> > perhaps there are also some use of
> > 	net_random() % non_const
> > that could be optimized a bit using this API.
> 
> I agree with you, needs to be evaluated on a case by case basis for future work.

__builtin_constant_p is useful.
