From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next] ath10k: wmi: Convert use of 6 to ETH_ALEN
Date: Thu, 3 Oct 2013 08:32:11 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1310030824570.2006@localhost6.localdomain6>
References: <1380679480.2081.24.camel@joe-AO722>  <87k3hw469z.fsf@kamboji.qca.qualcomm.com>  <1380696054.2081.35.camel@joe-AO722>  <CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>  <1380736969.2081.72.camel@joe-AO722>
 <alpine.DEB.2.02.1310030034030.2162@localhost6.localdomain6>  <1380758954.2081.79.camel@joe-AO722> <1380760114.2081.81.camel@joe-AO722>  <1380771110.2081.89.camel@joe-AO722> <1380771551.2081.93.camel@joe-AO722>  <1380773924.19002.131.camel@edumazet-glaptop.roam.corp.google.com>
  <87fvsjynuk.fsf@kamboji.qca.qualcomm.com>  <1380775478.19002.139.camel@edumazet-glaptop.roam.corp.google.com>  <1380776994.2081.101.camel@joe-AO722>  <1380777884.19002.155.camel@edumazet-glaptop.roam.corp.google.com> <1380778451.2081.103.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev <netdev@vger.kernel.org>, ath10k@lists.infradead.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:42415
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753531Ab3JCGcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 02:32:14 -0400
In-Reply-To: <1380778451.2081.103.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following semantic patch fixes the type declarations.  It should be 
run with the argument --recursive-includes for best (but slowest) results.

julia

@@
identifier x;
expression e1;
type T;
@@

T x[
- 6
+ ETH_ALEN
];
... when any
(
memcpy(x,e1,ETH_ALEN)
|
memcpy(e1,x,ETH_ALEN)
|
memset(x,e1,ETH_ALEN)
)

@r@
type T,T1;
identifier x;
@@

T {
...
T1 x[6];
...
};

@s@
r.T *e;
identifier r.x;
expression e1;
@@

(
memcpy(e->x,e1,ETH_ALEN)
|
memcpy(e1,e->x,ETH_ALEN)
|
memset(e->x,e1,ETH_ALEN)
)

@depends on s@
type r.T,r.T1;
identifier r.x;
@@

T {
...
T1 x[
-6
+ ETH_ALEN
 ];
...
};
