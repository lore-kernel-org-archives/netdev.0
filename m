From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next RFC 3/8] macvtap: introduce macvtap_get_vlan()
Date: Thu, 23 May 2013 19:11:07 +0400
Message-ID: <519E318B.2010804@cogentembedded.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com> <1369278753-2533-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369278753-2533-4-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 23-05-2013 7:12, Jason Wang wrote:

> Factor out the device holding logic to a macvtap_get_vlan(), this will be also
> used by multiqueue API.

> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/net/macvtap.c |   26 +++++++++++++++++++-------
>   1 files changed, 19 insertions(+), 7 deletions(-)

> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index ce1c72a..a36e49e 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -890,6 +890,23 @@ out:
>   	return ret;
>   }
>
> +static struct macvlan_dev *macvtap_get_vlan(struct macvtap_queue *q)
> +{
> +	struct macvlan_dev *vlan;

    Empty line wouldn't hurt here, after declaration.

> +	rcu_read_lock_bh();
> +	vlan = rcu_dereference_bh(q->vlan);
> +	if (vlan)
> +		dev_hold(vlan->dev);
> +	rcu_read_unlock_bh();
> +
> +	return vlan;
> +}
[...]

WBR, Sergei
