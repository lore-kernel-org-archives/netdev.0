From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net 0/1] Re: RFC: Fix "tc filter show" for basic filters
Date: Tue, 3 Feb 2015 18:32:34 +0100
Message-ID: <20150203173234.GA6246@zenon.in.qult.net>
References: <20150203141059.GA25454@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:53983 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S965602AbbBCRdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 12:33:01 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIhL1-00039d-RJ
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 18:32:35 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIhL0-0002C2-S5
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 18:32:34 +0100
Content-Disposition: inline
In-Reply-To: <20150203141059.GA25454@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

After some playing around, I found that my quick-and-dirty fix didn't a=
ctually
do the job.  I eventually traced the problem to come from the fact that
tcf_exts_dump_stats() just assumed that the list of actions in exts->ac=
tions
contains at least one element and accessed it using tcf_exts_first_act(=
).
This is clearly not true in the case of filters with no associated acti=
on in
particular, as in the case of my "basic" filter.

Simply ensuring that the list is not empty beforehand is enough to fix =
the
problem, just as is also done above in tcf_exts_dump().

Ignacy Gaw=EAdzki (1):
  cls_api.c: Fix dumping of non-existing actions' stats.

 net/sched/cls_api.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--=20
2.1.0
