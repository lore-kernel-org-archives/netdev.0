From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2 net-next 2/3] cxgb4: Adds support for T6 adapter
Date: Mon, 01 Jun 2015 20:43:37 -0700
Message-ID: <1433216617.4861.60.camel@perches.com>
References: <1433233780-17734-1-git-send-email-hariprasad@chelsio.com>
	 <1433233780-17734-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0169.hostedemail.com ([216.40.44.169]:37359 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755053AbbFBDnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 23:43:41 -0400
In-Reply-To: <1433233780-17734-3-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-02 at 13:59 +0530, Hariprasad Shenai wrote:
> Adds NIC driver related changes for T6 adapter. Register related
> changes, MC related changes, VF related changes, doorbell related
> changes, debugfs changes, etc

trivial notes:

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
[]
> @@ -1084,41 +1084,89 @@ static inline void tcamxy2valmask(u64 x, u64 y, u8 *addr, u64 *mask)
>  
>  static int mps_tcam_show(struct seq_file *seq, void *v)
>  {
> -	if (v == SEQ_START_TOKEN)
> -		seq_puts(seq, "Idx  Ethernet address     Mask     Vld Ports PF"
> -			 "  VF              Replication             "
> -			 "P0 P1 P2 P3  ML\n");
> -	else {
> +	struct adapter *adap = seq->private;
> +	unsigned int chip_ver = CHELSIO_CHIP_VERSION(adap->params.chip);
> +
> +	if (v == SEQ_START_TOKEN) {
> +		if (adap->params.arch.mps_rplc_size > 128)
> +			seq_puts(seq, "Idx  Ethernet address     Mask     "
> +				 "Vld Ports PF  VF                           "
> +				 "Replication                                "
> +				 "    P0 P1 P2 P3  ML\n");
> +		else
> +			seq_puts(seq, "Idx  Ethernet address     Mask     "
> +				 "Vld Ports PF  VF              Replication"
> +				 "	         P0 P1 P2 P3  ML\n");

Might as well add
	return 0;
here and unindent the block below:

> +	} else {
>  		u64 mask;
>  		u8 addr[ETH_ALEN];
[]
> +		if (chip_ver > CHELSIO_T5)
> +			seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x "
> +				   "%012llx%3c   %#x%4u%4d",
> +				   idx, addr[0], addr[1], addr[2], addr[3],

could use %pM and addr

[]

> +			seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x "
> +				   "%012llx%3c   %#x%4u%4d",
> +				   idx, addr[0], addr[1], addr[2], addr[3],
> +				   addr[4], addr[5], (unsigned long long)mask,

here too
