From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next resend] net/mlx4_core: pass pci_device_id.driver_data
 to __mlx4_init_one during reset
Date: Wed, 26 Mar 2014 18:02:27 +0400
Message-ID: <5332DDF3.2040703@cogentembedded.com>
References: <1395828952-11471-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Wei Yang <weiyang@linux.vnet.ibm.com>, jackm@dev.mellanox.co.il,
	ogerlitz@mellanox.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:36090 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755674AbaCZOCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:02:30 -0400
Received: by mail-la0-f48.google.com with SMTP id gf5so1500198lab.7
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 07:02:29 -0700 (PDT)
In-Reply-To: <1395828952-11471-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-03-2014 14:15, Wei Yang wrote:

> [Note: seems my network/mail system got some problem yesterday. Resend it in
> case it is lost. If you have already got one, please ignore it.]

    Put such remarks under --- tear line in the future, so that David don't 
have to edit them out when applying.

> The second parameter of __mlx4_init_one() is used to identify whether the
> pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
> this information is missed.

> This patch match the pci_dev with mlx4_pci_table and passes the
> pci_device_id.driver_data to __mlx4_init_one() in mlx4_pci_slot_reset().

> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/main.c |    6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index d711158..b083808 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2670,7 +2670,11 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>
>   static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>   {
> -	int ret = __mlx4_init_one(pdev, 0);
> +	const struct pci_device_id*  id;

    * should be close to 'id' and one space is enough. I guess you haven't run 
your patch thru scripts/checkpatch.pl?

WBR, Sergei
