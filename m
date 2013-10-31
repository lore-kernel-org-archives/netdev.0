From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next RFC 1/5] xen-netback: Introduce TX
 grant map definitions
Date: Thu, 31 Oct 2013 19:22:27 +0000
Message-ID: <5272ADF3.2000301@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com> <1383094220-14775-2-git-send-email-zoltan.kiss@citrix.com> <5270DF3602000078000FDFBE@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <jonathan.davies@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5270DF3602000078000FDFBE@nat28.tlf.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/10/13 09:28, Jan Beulich wrote:
>>>> On 30.10.13 at 01:50, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
>> @@ -119,13 +126,22 @@ struct xenvif {
>>   	pending_ring_idx_t pending_cons;
>>   	u16 pending_ring[MAX_PENDING_REQS];
>>   	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
>> +	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
>>
>>   	/* Coalescing tx requests before copying makes number of grant
>>   	 * copy ops greater or equal to number of slots required. In
>>   	 * worst case a tx request consumes 2 gnttab_copy.
>>   	 */
>>   	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
>> +	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
>> +	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
>> +	/* passed to gnttab_[un]map_refs with pages under (un)mapping */
>> +	struct page *pages_to_gnt[MAX_PENDING_REQS];
>
> I think you will want to try to limit the structure size here by putting
> things into unions that can't be used at the same time: Without
> having looked at the later patches yet, it seems quite unlikely that
> map and unmap can be used simultaneously. And the total of copy
> and map can't also be used at the same time, as for each pending
> request you would use either up to two copy slots or a single map
> slot. I didn't look for further opportunities of sharing space.

Indeed, map and unmap can't be done at the same time, so it's safe to 
put them into union. But I'm afraid grant_tx_handle and pages_to_gnt 
can't share space with other members.
tx_copy_ops is a different topic, let's discuss that in it's own thread ...

Thanks,

Zoli
