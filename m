From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH] netxen_nic: use spin_[un]lock_bh around tx_clean_lock
 (2)
Date: Thu, 7 May 2015 10:57:33 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B93E0A86312@avmb3.qlogic.org>
References: <1430917758-45028-1-git-send-email-tcamuso@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	"nhorman@redhat.com" <nhorman@redhat.com>
To: Tony Camuso <tcamuso@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430917758-45028-1-git-send-email-tcamuso@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Tony Camuso [mailto:tcamuso@redhat.com]
> Sent: Wednesday, May 06, 2015 6:39 PM
> To: linux-kernel; netdev
> Cc: Manish Chopra; Sony Chacko; Rajesh Borundia; nhorman@redhat.com
> Subject: [PATCH] netxen_nic: use spin_[un]lock_bh around tx_clean_lock (2)
> 
> This patch should have been part of the previous patch having the same
> summary. See  http://marc.info/?l=linux-kernel&m=143039470103795&w=2
> Unfortunately, I didn't check to see where else this lock was used before
> submitting that patch. This should take care of it for netxen_nic, as I did a
> thorough search this time.
> 
> To recap from the original patch; although testing this driver with
> DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled did not produce any traces, it
> would be more prudent in the case of tx_clean_lock to use _bh versions of
> spin_[un]lock, since this lock is manipulated in both the process and softirq
> contexts.
> 
> This patch was tested for functionality and regressions with netperf and
> DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled.
> 
> Signed-off-by: Tony Camuso <tcamuso@redhat.com>
> ---
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> index 2da9627..6301bae 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> @@ -1766,7 +1766,7 @@ int netxen_process_cmd_ring(struct netxen_adapter
> *adapter)
>  	int done = 0;
>  	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
> 
> -	if (!spin_trylock(&adapter->tx_clean_lock))
> +	if (!spin_trylock_bh(&adapter->tx_clean_lock))
>  		return 1;
> 
>  	sw_consumer = tx_ring->sw_consumer;
> @@ -1821,7 +1821,7 @@ int netxen_process_cmd_ring(struct netxen_adapter
> *adapter)
>  	 */
>  	hw_consumer = le32_to_cpu(*(tx_ring->hw_consumer));
>  	done = (sw_consumer == hw_consumer);
> -	spin_unlock(&adapter->tx_clean_lock);
> +	spin_unlock_bh(&adapter->tx_clean_lock);
> 
>  	return done;
>  }
> --
> 1.8.3.1

Acked-By: Manish Chopra <manish.chopra@qlogic.com>
