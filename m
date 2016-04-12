From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Tue, 12 Apr 2016 12:09:23 +0300
Message-ID: <CAJ3xEMg4_somMLXjQhcE3QN0uH_wd_86ue2x8SPm2f-t5AZH1w@mail.gmail.com>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
	<1460405422-8654-3-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMghu7ZB0YM8j_YJihpuNnDzOY2LU9-cTHwoWiBeYY7VPA@mail.gmail.com>
	<CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA@mail.gmail.com>
	<CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
	<20160412051537.GD25242@leon.nu>
	<CAJ3xEMijYrLvSmbNZp0B6AXqKGozz1rdZ58SCUP_09zOB6-2gQ@mail.gmail.com>
	<20160412060117.GA24649@leon.nu>
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
In-Reply-To: <20160412060117.GA24649-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2016 at 9:01 AM, Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org> wrote:
> On Tue, Apr 12, 2016 at 08:36:21AM +0300, Or Gerlitz wrote:

>> Conflicts happens @ all times, life.
>> I understand your desire to get it down to zero, but it's not gonna
>> work, pick another target.

> Maybe you are right and the time will show, but now we (Saeed, Matan and me)
> are trying hard to achieve this goal.

going with your approach, next you are going to define a goal of no RC time
conflicts between rdma and net, and this will slow down the already
terribly slow
(no 4.6 net mlx5 rc patches so far) process even further.

>> For example, the networking community has a fairly large rc activity
>> (I would say 10-20x
>> vs rdma), so when Dave does his "merge-rebases" for net-next over net
>> and linus tree
>> (4-5 times in a release), he has to this way or another solve
>> conflicts, yes! ditto for
>> Linus during merge windows and to some extent in rc times too.

> I don't see any harm in our desire to decrease work overhead from these
> busy people.

Desire is one thing, you took it too further to my taste.

>> > It won't help to anyone to split this commit to more than one patch.

>> The commit change-log should make it clear what this is about, and it doesn't.
>> If you believe in something, state that clear, be precise.

> I agree.

good, so please do that in the respin

>> As Saeed admitted the shared code in the commit spans maybe 2% of it.
>> The 1st commit deals with a field which is not used in the driver,
>> this is a cleanup
>> that you can do in rc (net) patch (remove the field all together) and
>> overall, w.o seeing

> I don't agree with your point that cleanup should go to RC.

>> the down-stream patches that depend on the newly introduced fields,
>> how do you know there aren't such (unused) bits in the 2nd commit?

> No, I don't know in advance, but the truth is that it doesn't bother
> anyone, because we are exposing our internal HW to kernel clients and
> doing it with minimal impact on the maintainers.

this is not the internal HW, it's the FW API and the FW API is stabilized
together with implementing the feature in the driver. We must not expose
unused fields since they might change/move or be eliminated as part of
the driver implementation and this creates extra noise and burden for other
developers and maintainers. The 1st patch should change to be elimination
of these two fields (cqe_zip_xxx and early VF enable) b/c they are not
used in the code.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
