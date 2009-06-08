From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Mon, 8 Jun 2009 11:16:28 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906081114530.21954@gentwo.org>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org> <20090603.224104.222901210.davem@davemloft.net> <alpine.DEB.1.10.0906041150590.3204@gentwo.org> <20090604.153057.178458221.davem@davemloft.net> <alpine.DEB.1.10.0906050959380.23895@gentwo.org>
 <adaeitywrfj.fsf@cisco.com> <alpine.DEB.1.10.0906051444360.29918@gentwo.org> <adabpp2v0y2.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:44448 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752038AbZFHPQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 11:16:34 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D9C4982C48B
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2009 11:31:55 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LyF7eWUKRdbS for <netdev@vger.kernel.org>;
	Mon,  8 Jun 2009 11:31:55 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B346782C494
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2009 11:31:49 -0400 (EDT)
In-Reply-To: <adabpp2v0y2.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Jun 2009, Roland Dreier wrote:

>
>  > This is actually better than IPoIB there is nothing before
>  > the initial traffic that arrives. In the IPoIB case 3 packets arrive
>  > suggesting to the other side that the link is okay.
>
> So maybe we should drop the *oldest* packet on queue overflow?  Would
> that make things better?

Definitely. That would avoid the apps thinking that there was a huge
outage. Also the join times on some fabrics can be quite long if there is
heavy reconfiguration of the switch fabric going on. In the
order of seconds it seems. The packet is definitely stale by that time.


