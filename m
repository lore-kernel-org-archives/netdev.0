From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] sfc: add support for skb->xmit_more
Date: Wed, 22 Oct 2014 13:36:21 +0100
Message-ID: <5447A4C5.90802@solarflare.com>
References: <1413219585-15854-1-git-send-email-dborkman@redhat.com>  <543C13AE.80606@solarflare.com> <543C2588.6060604@redhat.com>  <alpine.LFD.2.03.1410141933500.26972@solarflare.com>  <543FF408.3000808@solarflare.com>  <alpine.LFD.2.03.1410171512070.3218@solarflare.com> <1413968323.5994.6.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Stonehouse <rstonehouse@solarflare.com>,
	Daniel Borkmann <dborkman@redhat.com>, <davem@davemloft.net>,
	<nikolay@redhat.com>, <netdev@vger.kernel.org>,
	Shradha Shah <sshah@solarflare.com>,
	Jon Cooper <jcooper@solarflare.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:26487 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933170AbaJVMgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 08:36:32 -0400
In-Reply-To: <1413968323.5994.6.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/14 09:58, Ben Hutchings wrote:
> On Fri, 2014-10-17 at 15:32 +0100, Edward Cree wrote:
> [...]
>> @@ -351,7 +343,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
>>  	unsigned short dma_flags;
>>  	int i = 0;
>>  
>> -	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
>> +	EFX_BUG_ON_PARANOID(tx_queue->write_count > tx_queue->insert_count);
> [...]
>
> Doesn't this break after 2^32 descriptors?  It seems like you would need
> a similar comparison to time_after(); possibly:
>
> 	EFX_BUG_ON_PARANOID((int)(tx_queue->write_count - tx_queue->insert_count) > 0);
>
> Ben.
>
Yes, Jon already spotted that.  We just diked it out - see "[PATCH net]
sfc: remove incorrect EFX_BUG_ON_PARANOID check"
http://patchwork.ozlabs.org/patch/401503/
But your suggestion is a good one; feel free to post as a new patch on
that thread.
-Edward
