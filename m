From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 11/13] dmaengine: kill struct dma_client and supporting
	infrastructure
Date: Fri, 12 Dec 2008 14:29:47 +0000
Message-ID: <129600E5E5FB004392DDC3FB599660D70C8F3407@irsmsx504.ger.corp.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
 <20081114213513.32354.58256.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759433AbYLLOa0@vger.kernel.org>
In-Reply-To: <20081114213513.32354.58256.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Williams, Dan J wrote:
> All users have been converted to either the general-purpose allocator,
> dma_find_channel, or dma_request_channel.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
(...)
>  /**
> - * dma_chans_notify_available - broadcast available channels to the
> clients 
> - */
> -static void dma_clients_notify_available(void)
> -{
> -	struct dma_client *client;
> -
> -	mutex_lock(&dma_list_mutex);
> -
> -	list_for_each_entry(client, &dma_client_list, global_node)
> -		dma_client_chan_alloc(client);
> -
> -	mutex_unlock(&dma_list_mutex);
> -}

I agree with Guennadi's concern about removing clients' notification
of new devices available in the system.
I understand that this design is based on polling instead,
however polling is always less efficient approach.
Do you think that restoring notifications in this redesigned dmaengine
would be more painful than limiting clients to polling solution?

Regards,
Maciej