From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Tue, 12 Apr 2016 08:36:21 +0300
Message-ID: <CAJ3xEMijYrLvSmbNZp0B6AXqKGozz1rdZ58SCUP_09zOB6-2gQ@mail.gmail.com>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
	<1460405422-8654-3-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMghu7ZB0YM8j_YJihpuNnDzOY2LU9-cTHwoWiBeYY7VPA@mail.gmail.com>
	<CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA@mail.gmail.com>
	<CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
	<20160412051537.GD25242@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160412051537.GD25242-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2016 at 8:15 AM, Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org> wrote:
> On Tue, Apr 12, 2016 at 12:37:34AM +0300, Or Gerlitz wrote:
>> On Tue, Apr 12, 2016 at 12:24 AM, Saeed Mahameed
>> <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
>> > On Tue, Apr 12, 2016 at 12:17 AM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>
>> >> feature --> features
>>
>> > Correct, will fix.
>>
>> >>> * Add vport to steering commands for SRIOV ACL support
>> >>> * Add mlcr, pcmr and mcia registers for dump module EEPROM
>> >>> * Add support for FCS, baeacon led and disable_link bits to hca caps
>> >>> * Add CQE period mode bit in  CQ context for CQE based CQ
>> >>>   moderation support
>> >>> * Add umr SQ bit for fragmented memory registration
>> >>> * Add needed bits and caps for Striding RQ support
>>
>> >> AFAIK, all the above are features will go through net-next, what made
>> >> you anticipate conflicts with linux-rdma?
>>
>> > FCS bit is needed also for rdma, so we took the liberty of updating
>> > all the needed HW structs, bits, caps, etc ..
>> > at once for all mlx5 features planned for 4.7 regardless of rdma/net conflicts.
>>
>> The cover letter states that this series deals with shared code.
>>
>> I guess you might also could extend it a bit to deal also with code
>> that you suspect could lead to conflicts, but I don't see why it
>> evolved to that extent.
>
> Or,
> All these micro-optimizations on this shared file can potentially lead
> to undesired merge conflicts. Subsystem maintainers and Linus don't need to
> deal with these conflicts at all.

Leon,

Conflicts happens @ all times, life.

We (MLNX) didn't do a good job to minimize them as much as
possible on the 4.5 cycle (understatement) and did vast improvement
in the 4.6 cycle (one or two conflicts AFAIK and communicated  to Linus).

It's correct that Linus got really angry on these two conflicts but I have
communicated to him the fact that we did that improvement and we're talking
on two commits for a fairly large volume of patches, the response was, if you
do things right, we will happily keep working with you, people, go look.

I understand your desire to get it down to zero, but it's not gonna
work, pick another target.

For example, the networking community has a fairly large rc activity
(I would say 10-20x
vs rdma), so when Dave does his "merge-rebases" for net-next over net
and linus tree
(4-5 times in a release), he has to this way or another solve
conflicts, yes! ditto for
Linus during merge windows and to some extent in rc times too.

> It won't help to anyone to split this commit to more than one patch.

The commit change-log should make it clear what this is about, and it doesn't.
If you believe in something, state that clear, be precise.

As Saeed admitted the shared code in the commit spans maybe 2% of it.

The 1st commit deals with a field which is not used in the driver,
this is a cleanup
that you can do in rc (net) patch (remove the field all together) and
overall, w.o seeing
the down-stream patches that depend on the newly introduced fields,
how do you know there aren't such (unused) bits in the 2nd commit?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
