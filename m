From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] convert hh_lock to seqlock
Date: Thu, 07 Dec 2006 21:23:07 +0100
Message-ID: <4578782B.4010908@cosmosbay.com>
References: <20061207113309.2f892cf1@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604002mt.neufgp.fr ([84.96.92.61]:63313 "EHLO sMtp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1163340AbWLGVBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 16:01:50 -0500
Received: from [192.168.30.10] ([84.7.37.114]) by sp604002mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J9X003AM7A03PC0@sp604002mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 07 Dec 2006 21:22:49 +0100 (CET)
In-reply-to: <20061207113309.2f892cf1@localhost>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> The hard header cache is in the main output path, so using
> seqlock instead of reader/writer lock should reduce overhead.
>=20

Nice work Stephen, I am very interested.

Did you benchmarked it ?

I ask because I think hh_refcnt frequent changes may defeat the gain yo=
u want=20
(ie avoiding cache line ping pongs between cpus). seqlock are definitly=
 better=20
than rwlock, but if we really keep cache lines shared.

So I would suggest reordering fields of hh_cache and adding one=20
____cacheline_aligned_in_smp to keep hh_refcnt in another cache line.

(hh_len, hh_lock and hh_data should be placed on a 'mostly read' cache =
line)

Thank you
Eric

