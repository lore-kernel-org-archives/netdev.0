From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] NFC: nci: fix memory leak
Date: Wed, 9 Dec 2015 17:29:24 +0530
Message-ID: <20151209115924.GD24852@sudip-pc>
References: <1447678635-11146-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32825 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbbLIL7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 06:59:30 -0500
Content-Disposition: inline
In-Reply-To: <1447678635-11146-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2015 at 06:27:15PM +0530, Sudip Mukherjee wrote:
> In case of invalid number_destination_params we were returning error but
> we missed releasing cmd. Lets check for the number of parameter before
> allocating memory so that we don't have a memory leak.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---

A gentle ping.

regards
sudip


>  net/nfc/nci/core.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
> index 10c99a5..fbb7a2b 100644
> --- a/net/nfc/nci/core.c
> +++ b/net/nfc/nci/core.c
> @@ -610,14 +610,14 @@ int nci_core_conn_create(struct nci_dev *ndev, u8 destination_type,
>  	struct nci_core_conn_create_cmd *cmd;
>  	struct core_conn_create_data data;
>  
> +	if (!number_destination_params)
> +		return -EINVAL;
> +
>  	data.length = params_len + sizeof(struct nci_core_conn_create_cmd);
>  	cmd = kzalloc(data.length, GFP_KERNEL);
>  	if (!cmd)
>  		return -ENOMEM;
>  
> -	if (!number_destination_params)
> -		return -EINVAL;
> -
>  	cmd->destination_type = destination_type;
>  	cmd->number_destination_params = number_destination_params;
>  	memcpy(cmd->params, params, params_len);
> -- 
> 1.9.1
> 
