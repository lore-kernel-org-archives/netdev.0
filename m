From: Krishna Chaitanya <chaitanya.mgit@gmail.com>
Subject: Re: [PATCH 1/1] mac80211:Resetting connection monitor timers in
 transmit path
Date: Wed, 23 Oct 2013 16:24:23 +0530
Message-ID: <CABPxzYLdtA_gU87RY5pLqTxaq+NZbDyZVGwQ=vxj5HLdTz3C_w@mail.gmail.com>
References: <1382523145-2302-1-git-send-email-dhahira.thesneem@mistralsolutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Dhahira Thesneem <dhahira.thesneem@mistralsolutions.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382523145-2302-1-git-send-email-dhahira.thesneem@mistralsolutions.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 23, 2013 at 3:42 PM, Dhahira Thesneem
<dhahira.thesneem@mistralsolutions.com> wrote:
>
> Reset connection monitor timers when we are able to successfully transmit data to an AP.
>
> Signed-off-by: Dhahira Thesneem <dhahira.thesneem@mistralsolutions.com>
> ---
>  net/mac80211/tx.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
> index 3456c04..e7725cf 100644
> --- a/net/mac80211/tx.c
> +++ b/net/mac80211/tx.c
> @@ -1700,7 +1700,8 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct sk_buff *skb,
>
>         ieee80211_xmit(sdata, skb, chan->band);
>         rcu_read_unlock();
> -
> +       /*To reset connection monitor timers, after successful transmission*/
> +       ieee80211_sta_reset_conn_monitor(sdata);
>         return NETDEV_TX_OK;
>
>  fail_rcu:
> @@ -2139,7 +2140,8 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>
>         ieee80211_xmit(sdata, skb, band);
>         rcu_read_unlock();
> -
> +       /*To reset connection monitor timers, after successful transmission*/
> +       ieee80211_sta_reset_conn_monitor(sdata);
>         return NETDEV_TX_OK;
>
>   fail_rcu:
> --
Successful data transmission should be checked in the tx_status not
after we transmit.
In fact its already taken care in status.c: through ieee80211_sta_tx_notify.

NACK.
