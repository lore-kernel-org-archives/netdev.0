From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH v3] xen/grant-table: Avoid m2p_override during
 mapping
Date: Thu, 23 Jan 2014 13:05:50 +0000
Message-ID: <52E113AE.5060405@citrix.com>
References: <1390244288-3186-1-git-send-email-zoltan.kiss@citrix.com> <a6736948-c67e-4509-89a8-42ec9693830f@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a6736948-c67e-4509-89a8-42ec9693830f@email.android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/01/14 21:22, Konrad Rzeszutek Wilk wrote:
> Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
>> The grant mapping API does m2p_override unnecessarily: only gntdev
>> needs it,
>> for blkback and future netback patches it just cause a lock contention,
>> as
>> those pages never go to userspace. Therefore this series does the
>> following:
>> - the original functions were renamed to __gnttab_[un]map_refs, with a
>> new
>>   parameter m2p_override
>> - based on m2p_override either they follow the original behaviour, or
>> just set
>>   the private flag and call set_phys_to_machine
>> - gnttab_[un]map_refs are now a wrapper to call __gnttab_[un]map_refs
>> with
>>   m2p_override false
>> - a new function gnttab_[un]map_refs_userspace provides the old
>> behaviour
>
> You don't say anything about the 'return ret' changed to 'return 0'.
>
> Any particular reason for that?

That's the only possible return value there, so it just makes it more 
obvious. I'll add a description about that.

Zoli
