From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v2 2/2] xen-netback: Grant copy the
 header instead of map and memcpy
Date: Wed, 2 Apr 2014 15:41:38 +0100
Message-ID: <533C21A2.7030504@citrix.com>
References: <1396278539-27639-1-git-send-email-zoltan.kiss@citrix.com>	<1396278539-27639-2-git-send-email-zoltan.kiss@citrix.com> <1396352440.8667.117.camel@kazak.uk.xensource.com> <533C0C9F.8030205@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jonathan.davies@citrix.com>, <wei.liu2@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<paul.durrant@citrix.com>, <xen-devel@lists.xenproject.org>
To: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533C0C9F.8030205@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/04/14 14:11, David Vrabel wrote:
> On 01/04/14 12:40, Ian Campbell wrote:
>> On Mon, 2014-03-31 at 16:08 +0100, Zoltan Kiss wrote:
>>>
>>>   		__skb_put(skb, data_len);
>>> +		vif->tx_copy_ops[*copy_ops].source.u.ref = txreq.gref;
>>> +		vif->tx_copy_ops[*copy_ops].source.domid = vif->domid;
>>> +		vif->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
>>> +
>>> +		vif->tx_copy_ops[*copy_ops].dest.u.gmfn =
>>> +			virt_to_mfn(skb->data);
>>> +		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
>>> +		vif->tx_copy_ops[*copy_ops].dest.offset =
>>> +			offset_in_page(skb->data);
>>> +
>>> +		vif->tx_copy_ops[*copy_ops].len = data_len;
>>> +		vif->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
>>
>> We have gnttab_set_map_op. Should we have gnttap_set_copy_op too?
>
> A set of 3 might be useful I think.
>
> gnttab_set_copy_op_ref_to_gfn()
> gnttab_set_copy_op_gfn_to_ref()
> gnttab_set_copy_op_ref_to_ref()
I doubt it would increase clarity in any way, but I'll send a patch on 
top of these.

Zoli
