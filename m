From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Mon, 14 Apr 2008 22:28:52 +0200
Message-ID: <4803BE84.4040105@trash.net>
References: <47FFAFFA.7070802@superclick.com> <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Enrico Demarin <enrico@superclick.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50320 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921AbYDNUcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 16:32:10 -0400
In-Reply-To: <20080414202605.GA6164@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> [NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
>
> TC_H_MAJ(parentid) for root classes is the same as for ingress, and if
> ingress qdisc is created qdisc_lookup() returns its pointer (without
> ingress NULL is returned). After this all qdisc_lookups give the same,
> and we get endless loop. (I don't know how this could hide for so
> long - it should trigger with every leaf class deleted if it's qdisc
> isn't empty.)
>
> After this fix qdisc_lookup() is omitted both for ingress and root
> parents, but looking for root is only wasting a little time here...
> Many thanks to Enrico Demarin for finding a test for catching this
> bug, which probably bothered quite a lot of admins.
>   

Good catch, I agree that this is the reason for sure.

