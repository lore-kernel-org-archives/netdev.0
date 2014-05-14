From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 5/8] bridge: Add addresses from static fdbs to
 non-promisc ports
Date: Thu, 15 May 2014 00:44:51 +0400
Message-ID: <5373D5C3.60807@cogentembedded.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com> <1400080168-16625-6-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, john.r.fastabend@intel.com, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:47817 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbaENUou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 16:44:50 -0400
Received: by mail-lb0-f172.google.com with SMTP id l4so81557lbv.31
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 13:44:48 -0700 (PDT)
In-Reply-To: <1400080168-16625-6-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/14/2014 07:09 PM, Vlad Yasevich wrote:

> When a static fdb entry is created, add the mac address
> from this fdb entry to any ports that are currently running
> in non-promiscuous mode.  These ports need this data so that
> they can receive traffic destined to these addresses.
> By default ports start in promiscuous mode, so this feature
> is disabled.

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   net/bridge/br_fdb.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++-----
>   1 file changed, 70 insertions(+), 6 deletions(-)

> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9759b61..958b68a 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -85,8 +85,58 @@ static void fdb_rcu_free(struct rcu_head *head)
>   	kmem_cache_free(br_fdb_cache, ent);
>   }
>
> +/* When a static FDB entry is added, the mac address from the entry is
> + * added to the bridge private HW address list and all required ports
> + * are then updated with the new information.
> + * Called under RTNL.
> + */
> +static void fdb_add_hw(struct net_bridge *br, const unsigned char *addr)
> +{
> +	int err;
> +	struct net_bridge_port *p, *tmp = NULL;

    Initializer doesn't seem to be needed.

[...]

WBR, Sergei
