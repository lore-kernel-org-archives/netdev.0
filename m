From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC 1/3] tun: ethtool stats
Date: Fri, 6 Oct 2017 15:30:59 -0700
Message-ID: <20171006153059.193688a5@xeon-e3>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
        <20171006222516.90654-2-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:51120 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752095AbdJFWbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:31:07 -0400
Received: by mail-pg0-f49.google.com with SMTP id y7so1233713pgb.7
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:31:07 -0700 (PDT)
In-Reply-To: <20171006222516.90654-2-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  6 Oct 2017 18:25:14 -0400
Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:

> From: Willem de Bruijn <willemb@google.com>
> 
> Support ethtool -S on tun devices. This interface allows exporting
> device-specific stats not present in rtnl stats.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/tun.c | 38 ++++++++++++++++++++++++++++++++++++++
>  1 file changed, 38 insertions(+)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 57e4c31fa84a..df6ef9670d05 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -194,6 +194,15 @@ struct tun_flow_entry {
>  
>  #define TUN_NUM_FLOW_ENTRIES 1024
>  
> +static const struct {
> +	const char string[ETH_GSTRING_LEN];
> +} tun_ethtool_stats_keys[] = {
> +	{ "rx_packets" },
> +	{ "tx_packets" },
> +	{ "rx_bytes" },
> +	{ "tx_bytes" }

It looks like you are just exporting the statistics taht are already
through normal path. The purpose of ethtool stats is to provide
statistics unique to the device, not to repeat what is available throug
ip, ifconfig, etc.
