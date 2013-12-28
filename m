From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 20/20] net: caif: slight optimization of
 addr compare
Date: Fri, 27 Dec 2013 22:59:13 -0800
Message-ID: <1388213953.24123.2.camel@joe-AO722>
References: <52BE6D50.9000308@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>,
	Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BE6D50.9000308@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-12-28 at 14:18 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal
> to instead of memcmp.

This may be a distinction without difference, but
is a CAIF seghead also an ethernet address?

> diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
[]
> @@ -79,7 +79,7 @@ static struct cfpkt *rfm_append(struct cfrfml *rfml, char *seghead,
[]
>  	/* Verify correct header */
> -	if (memcmp(seghead, rfml->seghead, 6) != 0)
> +	if (!ether_addr_equal(seghead, rfml->seghead))
