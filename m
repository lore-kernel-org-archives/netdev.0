From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: don't indicate expiry on NTF_EXT_LEARNED
 fdb entries
Date: Fri, 17 Feb 2017 10:36:05 +0100
Message-ID: <feeb7b23-44cf-cbef-e014-723e8d0647dd@cumulusnetworks.com>
References: <1487281084-11769-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, idosch@mellanox.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34992 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751838AbdBQJgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 04:36:08 -0500
Received: by mail-wm0-f50.google.com with SMTP id v186so9402322wmd.0
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 01:36:08 -0800 (PST)
In-Reply-To: <1487281084-11769-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/02/17 22:38, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> added_by_external_learn fdb entries are added and expired by
> external entities like switchdev driver or external controllers.
> ageing is already disabled for such entries. Hence, don't
> indicate expiry for such fdb entries.
> 
> CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/bridge/br_fdb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 4ac1157..4f598dc 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -65,7 +65,7 @@ static inline unsigned long hold_time(const struct net_bridge *br)
>  static inline int has_expired(const struct net_bridge *br,
>  				  const struct net_bridge_fdb_entry *fdb)
>  {
> -	return !fdb->is_static &&
> +	return !fdb->is_static && !fdb->added_by_external_learn &&
>  		time_before_eq(fdb->updated + hold_time(br), jiffies);
>  }
>  
> 

Good catch,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
