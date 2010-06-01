From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Tue, 01 Jun 2010 12:31:50 +0200
Message-ID: <1275388310.2738.2.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1272056237.4599.7.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
	 <1272139861.20714.525.camel@edumazet-laptop>
	 <1272292568.13192.43.camel@jdb-workstation>
	 <1275340896.2478.26.camel@edumazet-laptop>
	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>
	 <1275368732.2478.88.camel@edumazet-laptop>  <4C04DE73.6050605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	paulmck@linux.vnet.ibm.com,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63757 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955Ab0FAKb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 06:31:56 -0400
In-Reply-To: <4C04DE73.6050605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 juin 2010 =C3=A0 12:18 +0200, Patrick McHardy a =C3=A9crit =
:

> If a new conntrack is created in PRE_ROUTING or LOCAL_OUT, it will be
> added to the unconfirmed list and moved to the hash as soon as the
> packet passes POST_ROUTING. This means the number of unconfirmed entr=
ies
> created by the network is bound by the number of CPUs due to BH
> processing. The number created by locally generated packets is unboun=
d
> in case of preemptible kernels however.
>=20

OK, we should have a percpu list then.

BTW, I notice nf_conntrack_untracked is incorrectly annotated
'__read_mostly'.

It can be written very often :(

Should'nt we special case it and let be really const ?



