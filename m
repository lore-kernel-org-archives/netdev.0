From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Tue, 15 Apr 2008 14:37:32 +0200
Message-ID: <4804A18C.2060200@trash.net>
References: <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local> <4803BE84.4040105@trash.net> <20080414.151102.169978802.davem@davemloft.net> <20080415053253.GA3920@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, enrico@superclick.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35952 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760720AbYDOMhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:37:42 -0400
In-Reply-To: <20080415053253.GA3920@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Apr 14, 2008 at 03:11:02PM -0700, David Miller wrote:
> ...
>>> Jarek Poplawski wrote:
> ...
>>>> After this fix qdisc_lookup() is omitted both for ingress and root
>>>> parents, but looking for root is only wasting a little time here...
> 
> ...Actually, there is yet a possibility that somebody uses ffff:
> handle for a qdisc (not ingress), which could make here a little
> difference, so this place could be improved for this case (even
> with something like my earlier debugging patch in this thread,
> which BTW could be a safety for maybe some other quirks here),
> but it seems it would be better to discourage using this handle
> for anything but ingress.


I don't think we should do that, it would be preferable to
compare the entire handle instead of just the major to avoid
this.

