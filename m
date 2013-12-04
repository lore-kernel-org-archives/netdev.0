From: Johannes Weiner <hannes@cmpxchg.org>
Subject: 2e685cad5790 build warning
Date: Wed, 4 Dec 2013 17:29:43 -0500
Message-ID: <20131204222943.GC21724@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Glauber Costa <glommer@gmail.com>, netdev@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zene.cmpxchg.org ([85.214.230.12]:44420 "EHLO zene.cmpxchg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753068Ab3LDW3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 17:29:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Sat Oct 19 16:26:19 2013 -0700

    tcp_memcontrol: Kill struct tcp_memcontrol
   =20
    Replace the pointers in struct cg_proto with actual data fields and=
 kill
    struct tcp_memcontrol as it is not fully redundant.
   =20
    This removes a confusing, unnecessary layer of abstraction.
   =20
    Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

triggers a build warning because it removed the only reference to a
function but not the function itself:

linux/net/ipv4/tcp_memcontrol.c:9:13: warning: =E2=80=98memcg_tcp_enter=
_memory_pressure=E2=80=99 defined but not used [-Wunused-function]
 static void memcg_tcp_enter_memory_pressure(struct sock *sk)

I can not see from the changelog why this function is no longer used,
or who is supposed to now set cg_proto->memory_pressure which you
still initialize etc.  Either way, the current state does not seem to
make much sense.  The author would be the best person to double check
such changes, but he wasn't copied on your patch, so I copied him now.

Apologies if this has been brought up before, I could not find any
reference on LKML of either this patch or a report of this warning.

Thanks!
