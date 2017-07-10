From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/mlx5: IPSec, fix 64-bit division correctly
Date: Mon, 10 Jul 2017 08:45:43 -0700
Message-ID: <1499701543.5468.11.camel@perches.com>
References: <20170710093842.2921914-1-arnd@arndb.de>
         <AM4PR0501MB194094863514236D1BE04C62DBA90@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ilan Tayari <ilant@mellanox.com>, Arnd Bergmann <arnd@arndb.de>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR0501MB194094863514236D1BE04C62DBA90@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-07-10 at 10:24 +0000, Ilan Tayari wrote:
> > -----Original Message-----
> > From: Arnd Bergmann [mailto:arnd@arndb.de]
> > Subject: [PATCH] net/mlx5: IPSec, fix 64-bit division correctly
> > 
> > The new IPSec offload code introduced a build error:
> > 
> > drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.o: In function
> > `mlx5e_ipsec_build_inverse_table':
> > ipsec_rxtx.c:(.text+0x556): undefined reference
> > 
> > Another patch was added on top to fix the build error, but
> > that introduced a new bug, as we now use the remainder of
> > the division rather than the result.

Is it possible to return noise in mlx5e_ipsec_mss_inv ?

What clamps skb_shinfo(skb)->gso_size to MAX_LSO
(the size of inverse_table)?

#define MAX_LSO_MSS 2048
static __be16 mlx5e_ipsec_inverse_table[MAX_LSO_MSS];

static inline __be16 mlx5e_ipsec_mss_inv(struct sk_buff *skb)
{
	return mlx5e_ipsec_inverse_table[skb_shinfo(skb)->gso_size];
}
