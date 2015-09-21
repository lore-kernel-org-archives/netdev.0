From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 08/38] openvswitch: fix handling result of ipv6_skip_exthdr
Date: Mon, 21 Sep 2015 10:45:57 -0700
Message-ID: <CALnjE+qFk_1xKjDHohT8PnjS0WDbC2WEZLb40DvJa2rzXye60Q@mail.gmail.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
	<1442842450-29769-9-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442842450-29769-9-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 21, 2015 at 6:33 AM, Andrzej Hajda <a.hajda@samsung.com> wrote:
> The function can return negative value.
>
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].
>
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2038576
>
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> ---
>  net/openvswitch/conntrack.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 002a755..fde3391 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -253,7 +253,7 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
>         const struct nf_conntrack_helper *helper;
>         const struct nf_conn_help *help;
>         enum ip_conntrack_info ctinfo;
> -       unsigned int protoff;
> +       int protoff;
>         struct nf_conn *ct;
>

A patch is already pushed to the net tree to fix this issue.
