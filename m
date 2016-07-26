From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Mon, 25 Jul 2016 17:37:01 -0700 (PDT)
Message-ID: <20160725.173701.1282720667210726281.davem@davemloft.net>
References: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, olaf@aepfle.de, gregkh@linuxfoundation.org,
 jasowang@redhat.com, dave.scott@docker.com, linux-kernel@vger.kernel.org,
 joe@perches.com, rolf.neugebauer@docker.com, netdev@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Sat, 23 Jul 2016 01:35:51 +0000

> +static struct sock *hvsock_create(struct net *net, struct socket *sock,
> +				  gfp_t priority, unsigned short type)
> +{
> +	struct hvsock_sock *hvsk;
> +	struct sock *sk;
> +
> +	sk = sk_alloc(net, AF_HYPERV, priority, &hvsock_proto, 0);
> +	if (!sk)
> +		return NULL;
 ...
> +	/* Looks stream-based socket doesn't need this. */
> +	sk->sk_backlog_rcv = NULL;
> +
> +	sk->sk_state = 0;
> +	sock_reset_flag(sk, SOCK_DONE);

All of these are unnecessary initializations, since sk_alloc() zeroes
out the 'sk' object for you.
