From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] vlan: adjust vlan_set_encap_proto() for its callers
Date: Sat, 23 Feb 2013 21:01:01 -0500 (EST)
Message-ID: <20130223.210101.591221456276487742.davem@davemloft.net>
References: <1361525547-21808-1-git-send-email-amwang@redhat.com>
	<1361525547-21808-2-git-send-email-amwang@redhat.com>
	<CAEP_g=_eWXuR_3zUYsbBiAjaCJQjRpSmUypqpJe5_jwN=rmM0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759379Ab3BXCBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 21:01:06 -0500
In-Reply-To: <CAEP_g=_eWXuR_3zUYsbBiAjaCJQjRpSmUypqpJe5_jwN=rmM0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 22 Feb 2013 17:05:01 -0800

> On Fri, Feb 22, 2013 at 1:32 AM, Cong Wang <amwang@redhat.com> wrote:
>> From: Cong Wang <amwang@redhat.com>
>>
>> There are two places to call vlan_set_encap_proto():
>> vlan_untag() and __pop_vlan_tci().
>>
>> vlan_untag() assumes skb->data points after mac addr, otherwise
>> the following code
>>
>>         vhdr = (struct vlan_hdr *) skb->data;
>>         vlan_tci = ntohs(vhdr->h_vlan_TCI);
>>         __vlan_hwaccel_put_tag(skb, vlan_tci);
>>
>>         skb_pull_rcsum(skb, VLAN_HLEN);
>>
>> won't be correct. But __pop_vlan_tci() assumes points _before_
>> mac addr.
>>
>> In vlan_set_encap_proto(), it looks for some magic L2 value
>> after mac addr:
>>
>>         rawp = skb->data;
>>         if (*(unsigned short *) rawp == 0xFFFF)
>>         ...
>>
>> Therefore __pop_vlan_tci() is obviously wrong.
>>
>> A quick fix is avoiding using skb->data in vlan_set_encap_proto(),
>> use 'vhdr+1' is always correct in both cases.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Jesse Gross <jesse@nicira.com>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Acked-by: Jesse Gross <jesse@nicira.com>

Applied, thanks.
