From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 06/20] ppp: slight optimization of addr compare
Date: Tue, 24 Dec 2013 20:24:57 +0400
Message-ID: <52B9B559.2060400@cogentembedded.com>
References: <52B96FCD.50901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Michal Ostrowski <mostrows@earthlink.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B96FCD.50901@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 24-12-2013 15:28, Ding Tianhong wrote:

> Use possibly more efficient ether_addr_equal
> to instead of memcmp.

> Cc: Michal Ostrowski <mostrows@earthlink.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/ppp/pppoe.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> index 82ee6ed..1808a10 100644
> --- a/drivers/net/ppp/pppoe.c
> +++ b/drivers/net/ppp/pppoe.c
> @@ -131,12 +131,13 @@ static inline struct pppoe_net *pppoe_pernet(struct net *net)
>
>   static inline int cmp_2_addr(struct pppoe_addr *a, struct pppoe_addr *b)
>   {
> -	return a->sid == b->sid && !memcmp(a->remote, b->remote, ETH_ALEN);
> +	return a->sid == b->sid && ether_addr_equal(a->remote,
> +							      b->remote);

    If it really doesn't fit insto single line, the continuation line should 
start right under 'a->remote'.

WBR, Sergei
