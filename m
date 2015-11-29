From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Date: Mon, 30 Nov 2015 00:58:03 +0300
Message-ID: <565B74EB.3000005@cogentembedded.com>
References: <20151126163413.GA3816@amd> <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com,
 chris.snook@gmail.com, netdev@vger.kernel.org,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org,
 nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com
To: Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@kernel.org>,
 davem@davemloft.net, Andrew Morton <akpm@osdl.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151128145113.GB4135@amd>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/28/2015 5:51 PM, Pavel Machek wrote:

> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> priority. That often breaks  networking after resume. Switch to
> GFP_KERNEL. Still not ideal, but should be significantly better.
>
> Signed-off-by: Pavel Machek <pavel@ucw.cz>
>
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 2795d6d..afb71e0 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -1016,10 +1016,10 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
>   		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
>   		8 * 4;
>
> -	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
> -				&ring_header->dma);
> +	ring_header->desc = dma_alloc_coherent(&pdev->dev, ring_header->size,
> +					       &ring_header->dma, GFP_KERNEL);
>   	if (unlikely(!ring_header->desc)) {
> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
> +		dev_err(&pdev->dev, "could not get memmory for DMA buffer\n");

     s/memmory/memory/.

[...]

MBR, Sergei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
