From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: add address and vlan to fdb warning
 messages
Date: Tue, 11 Oct 2016 15:17:20 -0700
Message-ID: <20161011151720.33f67320@xeon-e3>
References: <1476221632-18488-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nikolay@cumulusnetworks.com,
        netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32960 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754639AbcJKWRH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 18:17:07 -0400
Received: by mail-pf0-f176.google.com with SMTP id 128so8748839pfz.0
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 15:17:06 -0700 (PDT)
In-Reply-To: <1476221632-18488-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Oct 2016 14:33:51 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds vlan and address to warning messages printed
> in the bridge fdb code for debuggability.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/bridge/br_fdb.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 6b43c8c..1257a88 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -536,8 +536,8 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
>  		if (fdb->is_local)
>  			return 0;
>  		br_warn(br, "adding interface %s with same address "
> -		       "as a received packet\n",
> -		       source ? source->dev->name : br->dev->name);
> +		       "as a received packet (addr:%pM, vlan:%d)\n",
> +		       source ? source->dev->name : br->dev->name, addr, vid);
>  		fdb_delete(br, fdb);
>  	}
>  
> @@ -583,9 +583,10 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>  		/* attempt to update an entry for a local interface */
>  		if (unlikely(fdb->is_local)) {
>  			if (net_ratelimit())
> -				br_warn(br, "received packet on %s with "
> -					"own address as source address\n",
> -					source->dev->name);
> +				br_warn(br, "received packet on %s with own "
> +					"address as source address "
> +					"(addr:%pM, vlan:%d)\n",
> +					source->dev->name, addr, vid);
>  		} else {

Isn't vlan unsigned here so print with %u
Also it would be good to make string format on one line to allow for easy search of source.
				br_warn(br,
					"received packet on %s with own address %pM vlan %u",
					source->dev->name, addr, vid);
