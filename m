From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 3/7] openvswitch: Fix skb leak in ovs_fragment()
Date: Wed, 30 Sep 2015 17:42:17 +0300
Message-ID: <560BF4C9.7080509@cogentembedded.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
 <1443566380-22640-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org,
	pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443566380-22640-4-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/30/2015 01:39 AM, Joe Stringer wrote:

> If ovs_fragment() was unable to fragment the skb due to an L2 header
> that exceeds the supported length, skbs would be leaked. Fix the bug.
>
> Fixes: 7f8a436 "openvswitch: Add conntrack action"
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>   net/openvswitch/actions.c | 13 +++++++++----
>   1 file changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index e23a61c..e1afbd1 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
[...]
> @@ -728,8 +727,14 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
>   		WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
>   			  ovs_vport_name(vport), ntohs(ethertype), mru,
>   			  vport->dev->mtu);
> -		kfree_skb(skb);
> +		goto out;
>   	}
> +
> +	skb = NULL;

    I'd just return here.

> +
> +out:
> +	if (skb)
> +		kfree_skb(skb);

    kfree_skb() checks for NULL.

[...]

MBR, Sergei
