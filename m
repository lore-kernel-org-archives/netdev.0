From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 11/13] RDS: IB: add Fastreg MR (FRMR)
 detection support
Date: Sun, 28 Feb 2016 02:26:14 -0800
Message-ID: <56D2CB46.8010904@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
 <1456625990-4739-12-git-send-email-santosh.shilimkar@oracle.com>
 <20160228090858.GB6671@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160228090858.GB6671@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2/28/16 1:08 AM, Christoph Hellwig wrote:
> On Sat, Feb 27, 2016 at 06:19:48PM -0800, Santosh Shilimkar wrote:
>> Discovere Fast Memmory Registration support using IB device
>> IB_DEVICE_MEM_MGT_EXTENSIONS. Certain HCA might support just FRMR
>> or FMR or both FMR and FRWR. In case both mr type are supported,
>> default FMR is used.
>>
>> Default MR is still kept as FMR against what everyone else
>> is following. Default will be changed to FRMR once the
>> RDS performance with FRMR is comparable with FMR. The
>> work is in progress for the same.
>>
>> Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>> ---
>> v2: Dropped the module parameter as suggested by David Miller
>
> This means we only use the safer method if the HCA doesn't support
> the other one.  All other RDMA ULP that support both methods have
> a module_param so the veto from Dave is a bit unfortunate.  Anyway,
> let's get the code in for now and figure out what to use later.
>
Indeed. It wasn't really deal breaker for RDS so I agreed to drop it.

> Just curious:  where / how do you see worse peformance using FRs?
>
I wouldn't call it worse but its not comparable. Use case
is multi-threaded RDS RDMA perf test(s). Hopefully the follow
up series which am working on should minimise the gap. I am
leaving the details for later, but one of the main issue I
saw was contention on driver post_send() lock from send, MR reg
and MR invalidation.

Regards,
Santosh
