From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: a problem tcp_v4_err()
Date: Fri, 12 Nov 2010 20:57:15 +0300
Message-ID: <20101112175715.GB16544@ms2.inr.ac.ru>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com> <00c201cb81eb$84e18160$8ea48420$@com> <1289578108.3083.95.camel@localhost.localdomain> <1289578532.3185.265.camel@edumazet-laptop> <20101112163543.GB122902@jupiter.n2.diac24.net> <4CDD7145.8070606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Paris <eparis@redhat.com>, Hua Zhong <hzhong@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, paul.moore@hp.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CDD7145.8070606@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I looked at tcp_v4_err() and found something strange. Quite non-trivial operations
are performed on unlocked sockets. It looks like at least this BUG_ON():

                skb = tcp_write_queue_head(sk);
                BUG_ON(!skb);

can be easily triggered.

Do I miss something?

Alexey
