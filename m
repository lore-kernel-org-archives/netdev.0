From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [PATCH 0/2 RESEND] IB/Verbs: Use helpers to refine the checking
 on transport and link layer
Date: Fri, 27 Mar 2015 10:52:10 +0100
Message-ID: <5515284A.3030106@profitbricks.com>
References: <5512CFB0.1050108@profitbricks.com> <1427378940.21101.100.camel@redhat.com> <55142DFD.2060100@profitbricks.com> <1427387258.21101.124.camel@redhat.com> <55143AAC.8040206@profitbricks.com> <20150326211334.GA3359@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd@mellanox.c
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150326211334.GA3359-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, Jason

Thanks for the reply :-)

On 03/26/2015 10:13 PM, Jason Gunthorpe wrote:
> On Thu, Mar 26, 2015 at 05:58:20PM +0100, Michael Wang wrote:
>
>> The questions is just wondering how the transition method could be, but
>> if we have to do the changes for vendor, that sounds like a tough job...
> I would see changing how the information is represented in the struct
> as a follow on issue. The first patch should go through and replace
> all direct access to the link layer/transport/etc with an
> appropriately narrow is_XX() test like Doug was suggesting.

Sounds like a good plan, I'd like to change the second patch to
introduce these new helpers, later when we come to a good
solution, rework should be far more easier.

>
> That means looking at each code site and determining what it needs,
> making a is_XX for it and a kdoc describing exactly what is needed for
> the test to return true.

Basically I found there are three kind of check in current
implementation:

1. check transport type of device only
    I'd like to use helper has_XX(device)
    which means some port of the device has XX capability.

2. check link layer of device's port only
    I'd like to use helper cap_XX(device, port)
    which means the port has XX capability

3. check both the transport type and link layer
    I'd like to use helper tech_XX(device, port)
    which means the port of that device using technology
    ib, iwrap, iboe(roce) ...

>
> The follow on patch can then rework the is_XX and drop the link
> layer/transport stuff..
>
> Some ideas for is_XX:
>   IB compatible SA
>   QP0 SMP mechanism
>   IB SMP format
>   OPA SMP format
>   QP1 GMP mechanism
>   IB compatible CM
>   GID addressing
>   IP/IPv6 addressing
>   Ethernet VLAN
>   ...

Let's discuss and figure out the right name in the thread of
v2 patch set, I guess there will be a lot to be correct :-P

Regards,
Michael Wang

>
> Jason

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
