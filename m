From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] rds: Fix inaccurate accounting of unsignaled wrs
Date: Tue, 24 Oct 2017 09:36:22 -0700
Message-ID: <770ae898-346c-5932-04cb-68abd73b2625@oracle.com>
References: <20171024141628.14637-1-Haakon.Bugge@oracle.com>
 <e97ce8a5-4ad4-791b-2dd4-b3101999cca0@oracle.com>
 <663DF75A-36AC-4589-83B2-D664672CF374@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        OFED mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <haakon.bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <663DF75A-36AC-4589-83B2-D664672CF374-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/24/2017 9:15 AM, Håkon Bugge wrote:
> 
>> On 24 Oct 2017, at 18:05, Santosh Shilimkar 
>> <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org <mailto:santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>> 
>> wrote:
>>

[...]
>> Instead of partially doing changes inside/outside helper,
>> can also add inline helper for solicited state like
>> rds_ib_set_wr_solicited_state() and use that along
>> with this change.
> 
> Why? There is no book-keeping associated with setting send-solicited. 
> Its set on the last fragment of a message and on the last fragment sent 
> before throttling due to flow-control.
>
> Creating a function to perform:
> 
>          FOO |= BAR;
> 
> seems like an overkill to me.
>
Its just inline helper and keep code consistent for flag
manipulation. Compiler output will be like "FOO =| BAR;" :-)

> That being said, in my opinion the fragments of a (large) send should be 
> scattered with send-solicited. But that is another commit. But with such 
> a commit, I agree with you, a helper function is required.
> 
We already talked about it so lets leave it there.

Regards,
Santosh
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
