From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports from
	the host TCP port space.
Date: Tue, 7 Aug 2007 18:54:41 +0400
Message-ID: <20070807145441.GA24895@2ka.mipt.ru>
References: <46B883B5.8040702@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	OpenFabrics General <general@lists.openfabrics.org>,
	"David S. Miller" <davem@davemloft.net>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <46B883B5.8040702@opengridcomputing.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Steve.

On Tue, Aug 07, 2007 at 09:37:41AM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
> +static int cma_get_tcp_port(struct rdma_id_private *id_priv)
> +{
> +	int ret;
> +	struct socket *sock;
> +
> +	ret = sock_create_kern(AF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
> +	if (ret)
> +		return ret;
> +	ret = sock->ops->bind(sock,
> +			  (struct socketaddr 
> *)&id_priv->id.route.addr.src_addr,
> +			  ip_addr_size(&id_priv->id.route.addr.src_addr));

If get away from talks about broken offloading, this one will result in
the case, when usual network dataflow can enter private rdma land, i.e.
after bind succeeded this socket is accessible via any other network
device. Is it inteded?
And this is quite noticeble overhead per rdma connection, btw.

-- 
	Evgeniy Polyakov
