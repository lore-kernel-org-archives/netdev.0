From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [RFC PATCH] i40e: enable PCIe relax ordering
 for SPARC
Date: Tue, 6 Dec 2016 09:10:17 -0800
Message-ID: <CAKgT0UfTP+BrvDBzUJAVr9-DRCKgM7T3aS=LgRic8UZz8x82eg@mail.gmail.com>
References: <1480957627-16825-1-git-send-email-tushar.n.dave@oracle.com>
 <CAKgT0UcyRSub0NCi7oHX2Vf+N4vQxzwdWmcc+V+jOX_J=RYgfg@mail.gmail.com> <ec140d5d-3eec-5fc6-6417-11bacc55b807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: tndave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33946 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbcLFRKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:10:19 -0500
Received: by mail-io0-f194.google.com with SMTP id r94so7761729ioe.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:10:19 -0800 (PST)
In-Reply-To: <ec140d5d-3eec-5fc6-6417-11bacc55b807@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 5, 2016 at 2:23 PM, tndave <tushar.n.dave@oracle.com> wrote:
>
>
> On 12/05/2016 01:54 PM, Alexander Duyck wrote:
>>
>> On Mon, Dec 5, 2016 at 9:07 AM, Tushar Dave <tushar.n.dave@oracle.com>
>> wrote:
>>>
>>> Unlike previous generation NIC (e.g. ixgbe) i40e doesn't seem to have
>>> standard CSR where PCIe relaxed ordering can be set. Without PCIe relax
>>> ordering enabled, i40e performance is significantly low on SPARC.
>>>
>>> This patch sets PCIe relax ordering for SPARC arch by setting dma attr
>>> DMA_ATTR_WEAK_ORDERING for every tx and rx DMA map/unmap.
>>> This has shown 10x increase in performance numbers.
>>>
>>> e.g.
>>> iperf TCP test with 10 threads on SPARC S7
>>>
>>> Test 1: Without this patch
>>>
>>> # iperf -s
>>> ------------------------------------------------------------
>>> Server listening on TCP port 5001
>>> TCP window size: 85.3 KByte (default)
>>> ------------------------------------------------------------
>>> [  4] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40926
>>> [  5] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40934
>>> [  6] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40930
>>> [  7] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40928
>>> [  8] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40922
>>> [  9] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40932
>>> [ 10] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40920
>>> [ 11] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40924
>>> [ 14] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40982
>>> [ 12] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40980
>>> [ ID] Interval       Transfer     Bandwidth
>>> [  4]  0.0-20.0 sec   566 MBytes   237 Mbits/sec
>>> [  5]  0.0-20.0 sec   532 MBytes   223 Mbits/sec
>>> [  6]  0.0-20.0 sec   537 MBytes   225 Mbits/sec
>>> [  8]  0.0-20.0 sec   546 MBytes   229 Mbits/sec
>>> [ 11]  0.0-20.0 sec   592 MBytes   248 Mbits/sec
>>> [  7]  0.0-20.0 sec   539 MBytes   226 Mbits/sec
>>> [  9]  0.0-20.0 sec   572 MBytes   240 Mbits/sec
>>> [ 10]  0.0-20.0 sec   604 MBytes   253 Mbits/sec
>>> [ 14]  0.0-20.0 sec   567 MBytes   238 Mbits/sec
>>> [ 12]  0.0-20.0 sec   511 MBytes   214 Mbits/sec
>>> [SUM]  0.0-20.0 sec  5.44 GBytes  2.33 Gbits/sec
>>>
>>> Test 2: with this patch:
>>>
>>> # iperf -s
>>> ------------------------------------------------------------
>>> Server listening on TCP port 5001
>>> TCP window size: 85.3 KByte (default)
>>> ------------------------------------------------------------
>>> TCP: request_sock_TCP: Possible SYN flooding on port 5001. Sending
>>> cookies.  Check SNMP counters.
>>> [  4] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46876
>>> [  5] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46874
>>> [  6] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46872
>>> [  7] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46880
>>> [  8] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46878
>>> [  9] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46884
>>> [ 10] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46886
>>> [ 11] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46890
>>> [ 12] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46888
>>> [ 13] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46882
>>> [ ID] Interval       Transfer     Bandwidth
>>> [  4]  0.0-20.0 sec  7.45 GBytes  3.19 Gbits/sec
>>> [  5]  0.0-20.0 sec  7.48 GBytes  3.21 Gbits/sec
>>> [  7]  0.0-20.0 sec  7.34 GBytes  3.15 Gbits/sec
>>> [  8]  0.0-20.0 sec  7.42 GBytes  3.18 Gbits/sec
>>> [  9]  0.0-20.0 sec  7.24 GBytes  3.11 Gbits/sec
>>> [ 10]  0.0-20.0 sec  7.40 GBytes  3.17 Gbits/sec
>>> [ 12]  0.0-20.0 sec  7.49 GBytes  3.21 Gbits/sec
>>> [  6]  0.0-20.0 sec  7.30 GBytes  3.13 Gbits/sec
>>> [ 11]  0.0-20.0 sec  7.44 GBytes  3.19 Gbits/sec
>>> [ 13]  0.0-20.0 sec  7.22 GBytes  3.10 Gbits/sec
>>> [SUM]  0.0-20.0 sec  73.8 GBytes  31.6 Gbits/sec
>>>
>>> NOTE: In my testing, this patch does _not_ show any harm to i40e
>>> performance numbers on x86.
>>>
>>> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
>>
>>
>> You went through and replaced all of the dma_unmap/map_page calls with
>> dma_map/unmap_single_attrs  I would prefer you didn't do that.  I have
>
> Yes, because currently there is no DMA API for dma_map/unmap_page with dma
> attr*
>>
>> patches to add the ability to map and unmap pages with attributes that
>> should be available for 4.10-rc1 so if you could wait on this patch
>> until then it would be preferred.
>
> :-) thanks. I will wait until your patches are out.
>
>>
>>> ---
>>>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 69
>>> ++++++++++++++++++++---------
>>>  drivers/net/ethernet/intel/i40e/i40e_txrx.h |  1 +
>>>  2 files changed, 49 insertions(+), 21 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>>> b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>>> index 6287bf6..800dca7 100644
>>> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>>> @@ -551,15 +551,17 @@ static void i40e_unmap_and_free_tx_resource(struct
>>> i40e_ring *ring,
>>>                 else
>>>                         dev_kfree_skb_any(tx_buffer->skb);
>>>                 if (dma_unmap_len(tx_buffer, len))
>>> -                       dma_unmap_single(ring->dev,
>>> -                                        dma_unmap_addr(tx_buffer, dma),
>>> -                                        dma_unmap_len(tx_buffer, len),
>>> -                                        DMA_TO_DEVICE);
>>> +                       dma_unmap_single_attrs(ring->dev,
>>> +                                              dma_unmap_addr(tx_buffer,
>>> dma),
>>> +                                              dma_unmap_len(tx_buffer,
>>> len),
>>> +                                              DMA_TO_DEVICE,
>>> +                                              ring->dma_attrs);
>>>         } else if (dma_unmap_len(tx_buffer, len)) {
>>> -               dma_unmap_page(ring->dev,
>>> -                              dma_unmap_addr(tx_buffer, dma),
>>> -                              dma_unmap_len(tx_buffer, len),
>>> -                              DMA_TO_DEVICE);
>>> +               dma_unmap_single_attrs(ring->dev,
>>> +                                      dma_unmap_addr(tx_buffer, dma),
>>> +                                      dma_unmap_len(tx_buffer, len),
>>> +                                      DMA_TO_DEVICE,
>>> +                                      ring->dma_attrs);
>>>         }
>>>
>>>         tx_buffer->next_to_watch = NULL;
>>> @@ -662,6 +664,8 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
>>>         struct i40e_tx_buffer *tx_buf;
>>>         struct i40e_tx_desc *tx_head;
>>>         struct i40e_tx_desc *tx_desc;
>>> +       dma_addr_t addr;
>>> +       size_t size;
>>>         unsigned int total_bytes = 0, total_packets = 0;
>>>         unsigned int budget = vsi->work_limit;
>>>
>>> @@ -696,10 +700,11 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
>>>                 napi_consume_skb(tx_buf->skb, napi_budget);
>>>
>>>                 /* unmap skb header data */
>>> -               dma_unmap_single(tx_ring->dev,
>>> -                                dma_unmap_addr(tx_buf, dma),
>>> -                                dma_unmap_len(tx_buf, len),
>>> -                                DMA_TO_DEVICE);
>>> +               dma_unmap_single_attrs(tx_ring->dev,
>>> +                                      dma_unmap_addr(tx_buf, dma),
>>> +                                      dma_unmap_len(tx_buf, len),
>>> +                                      DMA_TO_DEVICE,
>>> +                                      tx_ring->dma_attrs);
>>>
>>>                 /* clear tx_buffer data */
>>>                 tx_buf->skb = NULL;
>>> @@ -717,12 +722,15 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
>>>                                 tx_desc = I40E_TX_DESC(tx_ring, 0);
>>>                         }
>>>
>>> +                       addr = dma_unmap_addr(tx_buf, dma);
>>> +                       size = dma_unmap_len(tx_buf, len);
>>
>>
>> On some architectures this change could lead to issues since
>> dma_unmap_len could be 0 meaning that addr would never be used.
>
> I see. Thanks.
>
>>
>>>                         /* unmap any remaining paged data */
>>>                         if (dma_unmap_len(tx_buf, len)) {
>>> -                               dma_unmap_page(tx_ring->dev,
>>> -                                              dma_unmap_addr(tx_buf,
>>> dma),
>>> -                                              dma_unmap_len(tx_buf,
>>> len),
>>> -                                              DMA_TO_DEVICE);
>>> +                               dma_unmap_single_attrs(tx_ring->dev,
>>> +                                                      addr,
>>> +                                                      size,
>>> +                                                      DMA_TO_DEVICE,
>>> +
>>> tx_ring->dma_attrs);
>>>                                 dma_unmap_len_set(tx_buf, len, 0);
>>>                         }
>>>                 }
>>> @@ -1010,6 +1018,11 @@ int i40e_setup_tx_descriptors(struct i40e_ring
>>> *tx_ring)
>>>          */
>>>         tx_ring->size += sizeof(u32);
>>>         tx_ring->size = ALIGN(tx_ring->size, 4096);
>>> +#ifdef CONFIG_SPARC
>>> +       tx_ring->dma_attrs = DMA_ATTR_WEAK_ORDERING;
>>> +#else
>>> +       tx_ring->dma_attrs = 0;
>>> +#endif
>>>         tx_ring->desc = dma_alloc_coherent(dev, tx_ring->size,
>>>                                            &tx_ring->dma, GFP_KERNEL);
>>>         if (!tx_ring->desc) {
>>
>>
>> Also not a fan of adding yet ring attribute.  Is there any reason why
>> you couldn't simply add a set of inline functions at the start of
>> i40e_txrx.c that could replace the DMA map/unmap operations in this
>> code but pass either 0 or DMA_ATTR_WEAK_ORDERING as needed for the
>> drivers?  Then the x86 code doesn't have to change while the SPARC
>> code will be able to be passed the attribute.
>
> Sure I can do that.
>
> I will follow up with patch after your patches for map/unmap page with dma
> attr will be out.
>
> Thanks.
>
> -Tushar
>

I was thinking about it and I realized we can probably simplify this
even further.  In the case of most other architectures the
DMA_ATTR_WEAK_ORDERING has no effect anyway.  So from what I can tell
there is probably no reason not to just always pass that attribute
with the DMA mappings.  From what I can tell the only other
architecture that uses this is the PowerPC Cell architecture.

Also I was wondering if you actually needed to enable this attribute
for both Rx and Tx buffers or just Rx buffers?  The patch that enabled
DMA_ATTR_WEAK_ORDERING for Sparc64 seems to call out writes, but I
didn't see anything about reads.  I'm just wondering if changing the
code for Tx has any effect?  If not you could probably drop those
changes and just focus on Rx.

Thanks.

- Alex
