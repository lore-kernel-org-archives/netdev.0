From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 1/2] net: pktgen: support injecting packets
 for qdisc testing
Date: Thu, 30 Jun 2016 09:42:01 -0700
Message-ID: <57754BD9.5010709@gmail.com>
References: <20160629200306.16491.65359.stgit@john-Precision-Tower-5810>
 <20160630103758.37bc8d6f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34918 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbcF3Q55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 12:57:57 -0400
Received: by mail-oi0-f68.google.com with SMTP id d132so8433150oig.2
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 09:57:57 -0700 (PDT)
In-Reply-To: <20160630103758.37bc8d6f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-30 01:37 AM, Jesper Dangaard Brouer wrote:
> On Wed, 29 Jun 2016 13:03:06 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> Add another xmit_mode to pktgen to allow testing xmit functionality
>> of qdiscs. The new mode "queue_xmit" injects packets at
>> __dev_queue_xmit() so that qdisc is called.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> I generally like this.
> 

[...]

>> @@ -3434,6 +3442,36 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>>  #endif
>>  		} while (--burst > 0);
>>  		goto out; /* Skips xmit_mode M_START_XMIT */
>> +	} else if (pkt_dev->xmit_mode == M_QUEUE_XMIT) {
>> +		local_bh_disable();
>> +		atomic_add(burst, &pkt_dev->skb->users);
> 
> Reading the code, people might think that "burst" is allowed for this
> mode, which it is not. (You do handle this earlier in this patch when
> configuring this mode).

Right we never get here without burst == 1 but sure it does read
a bit strange I'll use atomic_inc().


Thanks,
John
