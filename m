From: Nuno Silva <nuno.silva@vgertech.com>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0
 to become free. Usage count = 1
Date: Mon, 23 Aug 2004 18:56:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412A2FC5.8090402@vgertech.com>
References: <E1BynUy-0007t1-00@gondolin.me.apana.org.au> <4128941D.9030000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Herbert Xu <herbert@gondor.apana.org.au>, linux-kernel@vger.kernel.org,
        master@sectorb.msk.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4128941D.9030000@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Patrick McHardy wrote:
| Herbert Xu wrote:
|
|> Nuno Silva <nuno.silva@vgertech.com> wrote:
|>
|>
|>> The problem is in the QoS code. If I start ppp whithout the
|>
|>
|> OK, this appears to be due to the changeset titled
|>
|> [PKT_SCHED]: Refcount qdisc->dev for __qdisc_destroy rcu-callback
|>
|> It adds a reference to dev.
|>
|> I don't see any code that cleans up that reference when the dev goes
|> down.  So someone needs to add that similar to the code in
|> net/core/dst.c.
|>
|> Patrick, could you please have a look at this?
|>
|>
| The reference is dropped in __qdisc_destroy. The problem lies in the CBQ
| qdisc, it doesn't destroy the root-class and leaks the inner qdisc. These
| two patches for 2.4 and 2.6 fix the problem.

Hi!

Just to give some feedback: IT WORKS! Thanks!

Didn't try with 2.4, but it works very well with 2.6.8.1.
Thanks again,
Nuno Silva

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBKi/FOPig54MP17wRAiYBAJ41ZGzauhY6dDVtylWkLSD3V+vx9QCgteNF
21sEmv0wqP+9hdnXEc4DNBE=
=ByPY
-----END PGP SIGNATURE-----
