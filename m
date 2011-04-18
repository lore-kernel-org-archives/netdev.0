From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Subject: Re: [PATCH 24/27] HFI: hf network driver
Date: Sun, 17 Apr 2011 23:21:20 -0400
Message-ID: <4DABAE30.9080308@linux.vnet.ibm.com>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com> <1299100213-8770-24-git-send-email-dykmanj@linux.vnet.ibm.com> <20110302142617.112bd9cb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35248 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab1DRDVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 23:21:24 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I3AM2u028483
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:10:22 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3I3LNQ3114918
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:21:24 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3LNSI016565
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:21:23 -0600
In-Reply-To: <20110302142617.112bd9cb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2011 5:26 PM, Stephen Hemminger wrote:
> On Wed,  2 Mar 2011 16:10:10 -0500
> dykmanj@linux.vnet.ibm.com wrote:
> 
>> +struct hf_if {
>> +	u32			idx;			/* 0, 1, 2, 3 ...   */
>> +	u32			ai;			/* 0=hfi0, 1=hfi1   */
>> +	char			name[HF_MAX_NAME_LEN];
>> +	u32			isr_id;
>> +	u32			ip_addr;
>> +	u32			state;			/* CLOSE, OPEN */
>> +	spinlock_t		lock;			/* lock for state */
>> +	u32			sfifo_fv_polarity;
>> +	u32			sfifo_slots_per_blk;
>> +	u32			sfifo_packets;
>> +	void __iomem		*doorbell;		/* mapped mmio_regs */
>> +	struct hf_fifo		tx_fifo;
>> +	struct hf_fifo		rx_fifo;
>> +	struct hfi_client_info	client;
>> +	struct sk_buff		**tx_skb;		/* array to store tx
>> +							   2k skb */
>> +	void			*sfifo_finishvec;
>> +	struct net_device_stats	net_stats;
>> +};
> 
> You don't need net_stats in this structure if you use
> the standard netdev->stats structure instead.
> 
> You won't need hf_get_stats then..
> 
Ok, done in v2

Jim

