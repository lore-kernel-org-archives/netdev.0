From: David Daney <ddaney@avtrex.com>
Subject: Re: [PATCH] e100: Add missing dma sync for proper
 operation with non-coherent caches.
Date: Tue, 26 Aug 2008 12:24:31 -0700
Message-ID: <48B4586F.6030201@avtrex.com>
References: <48B3A8D0.2040108@avtrex.com> <48B45065.5050907@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-mips <linux-mips@linux-mips.org>
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <48B45065.5050907@roinet.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Acker wrote:
> David Daney wrote:

>> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
>> index 19d32a2..fb8d551 100644
>> --- a/drivers/net/e100.c
>> +++ b/drivers/net/e100.c
>> @@ -1840,6 +1840,11 @@ static int e100_rx_indicate(struct nic *nic, 
>> struct rx *rx,
>>  
>>              if (readb(&nic->csr->scb.status) & rus_no_res)
>>                  nic->ru_running = RU_SUSPENDED;
>> +        /* We are done looking at the buffer.  Prepare it for
>> +         * more DMA.  */
>> +        pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
>> +                           sizeof(struct rfd),
>> +                           PCI_DMA_FROMDEVICE);
>>          return -ENODATA;
>>      }
>>  
> Should the call to pci_dma_sync_single_for_device be DMA_TO_DEVICE since 
> we are giving the memory back to the device?

No.  We are giving the memory back to the device, but the direction of 
the data transfer is from the device to memory.

David Daney

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
