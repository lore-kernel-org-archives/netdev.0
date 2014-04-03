From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] grant-table,
 xen-netback: Introduce helper functions for grant copy operations
Date: Thu, 3 Apr 2014 10:48:58 +0100
Message-ID: <533D2E8A.90101@citrix.com>
References: <1396458349-30112-1-git-send-email-zoltan.kiss@citrix.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD02BB106@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stefano Stabellini <Stefano.Stabellini@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD02BB106@AMSPEX01CL01.citrite.net>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On 03/04/14 09:12, Paul Durrant wrote:
> Zoltan Kiss wrote:
>>
>> Create helper functions for grant copy operations and use them in netback.
>>
[...]
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -275,23 +275,29 @@ static void xenvif_gop_frag_copy(struct xenvif *vif,
>> struct sk_buff *skb,
>>  			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
>>
>>  		copy_gop = npo->copy + npo->copy_prod++;
>> -		copy_gop->flags = GNTCOPY_dest_gref;
>> -		copy_gop->len = bytes;
>>
>>  		if (foreign_vif) {
>> -			copy_gop->source.domid = foreign_vif->domid;
>> -			copy_gop->source.u.ref = foreign_gref;
>> -			copy_gop->flags |= GNTCOPY_source_gref;
>> +			gnttab_set_copy_op_ref_to_ref(copy_gop,
>> +						      foreign_gref,
>> +						      npo->copy_gref,
>> +						      foreign_vif->domid,
>> +						      offset,
>> +						      vif->domid,
>> +						      npo->copy_off,
>> +						      bytes,
>> +						      GNTCOPY_dest_gref |
>> +						      GNTCOPY_source_gref);
> 
> Can't you lose the flags here (and in the other variants)? Since
> they are implied by the variant of the function they could just be hardcoded
> there, couldn't they?

Even with that change these are still functions with 7 or 8 parameters
with no obvious order.  That's just awful.  The open-coded struct
initialization is better.

David
