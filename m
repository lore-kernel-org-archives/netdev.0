From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] ipip, sit: fix ipv4_{update_pmtu,redirect} calls
Date: Fri, 6 Jun 2014 17:45:44 -0700
Message-ID: <CAHA+R7NUVPz47AKCTk7nYBkZXK=93vJOO8f6FTkyU0UkU6Q30Q@mail.gmail.com>
References: <20140606231921.2ff39106ac54216fd9170fae@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	trivial@kernel.org
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140606231921.2ff39106ac54216fd9170fae@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 6, 2014 at 12:19 PM, Dmitry Popov <ixaphire@qrator.net> wrote:
> ipv4_{update_pmtu,redirect} were called with tunnel's ifindex (t->dev is a
> tunnel netdevice). It caused wrong route lookup and failure of pmtu update or
> redirect. We should use the same ifindex that we use in ip_route_output_* in
> *tunnel_xmit code. It is t->parms.link .
>
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
> ---
>  net/ipv4/ipip.c | 4 ++--
>  net/ipv6/sit.c  | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)

I think vti (v4 and v6) tunnel needs to fix as well?
