From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 01 Nov 2007 20:17:35 +0100
Message-ID: <472A264F.8040201@cosmosbay.com>
References: <4729A774.9030409@cosmosbay.com>	<20071101091456.26248ce0@freepuppy.rosehill> <472A12D0.4070401@cosmosbay.com> <472A1F8A.2070708@hp.com> <472A2251.4000701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39465 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535AbXKATSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 15:18:38 -0400
In-Reply-To: <472A2251.4000701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Rick Jones a =E9crit :
> Something is telling me finding a 64 core system with a suitable=20
> workload to try this could be a good thing.  Wish I had one at my=20
> disposal.

Maybe on big NUMA machines, we might prefer to spread the rwlock array =
on=20
multiple nodes (ie using vmalloc() instead of kmalloc())

After my patch, it is true all rwlocks are on one memory node. Not exac=
tly=20
optimal :(

But if it was an issue, the spinlock array used in IP route cache would=
 have=20
the same problem and *someone* should already have complained...


