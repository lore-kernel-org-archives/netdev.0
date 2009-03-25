From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: Use hlist_add_head_rcu() in nf_conntrack_set_hashsize()
Date: Wed, 25 Mar 2009 17:26:47 +0100
Message-ID: <49CA5B47.4010400@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49C93A8D.8000603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34071 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbZCYQ05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 12:26:57 -0400
In-Reply-To: <49C93A8D.8000603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> While working on this stuff, I found one suspect use of hlist_add_head()
> 
> Its not a hot path, I believe following patch would make sure nothing
> wrong happens.
> 
> If a chain contains element A and B, then we might build a new table
> with a new chain containing B and A (in this reverse order), and
> a cpu could see A->next = B (new pointer),  B->next = A (old pointer)

I think you're right.

> [PATCH] netfilter: Use hlist_add_head_rcu() in nf_conntrack_set_hashsize()
> 
> Using hlist_add_head() in nf_conntrack_set_hashsize() is quite dangerous.
> Without any barrier, one CPU could see a loop while doing its lookup.
> Its true new table cannot be seen by another cpu, but previous table is still
> readable.

Applied, thanks Eric.
