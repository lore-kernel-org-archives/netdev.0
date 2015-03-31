From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
Date: Tue, 31 Mar 2015 15:22:59 +0200
Message-ID: <551A9FB3.2030903@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>		 <55157B43.6060507@profitbricks.com>	 <1427732191.21101.201.camel@redhat.com> <55197CDB.3040105@profitbricks.com> <1427734923.21101.227.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Alex Estrin <alex.estrin@int
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427734923.21101.227.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/30/2015 07:02 PM, Doug Ledford wrote:
> On Mon, 2015-03-30 at 18:42 +0200, Michael Wang wrote:
>> [snip]
>>
>> rdma_transport_is_ib and rdma_port_ll_is_ib is actually just rough helper
>> to save some code, we can get rid of them when we no longer need them, but
>> currently device driver still using them a lot, I'm not sure if the new
>> mechanism could take cover all these cases...
> [snip]
>
> If we use something like this, then the above is all you need.  Then
> every place in the code that checks for something like has_sa or cap_sa
> can be replaced with rdma_ib_mgmt.  When Ira updates his patches for
> this, he can check for rdma_opa_mgmt to enable jumbo MAD packets and
> whatever else he needs. Every place that does transport == IB and ll ==
> Ethernet can become rdma_transport_is_roce.  Every place that does
> transport == IB and ll == INFINIBAND becomes rdma_transport_is_ib.

Get your point :-) I need to investigate all those cases see if it
works, in case if things unclear, I'll reform it according to my
understanding to adapt to this new mechanism, if there are any
misunderstanding, we can address them case by case during
the review.

>  The
> code in multicast.c just needs to check rdma_ib_mgmt() (which happens to
> make perfect sense anyway as the code in multicast.c that is checking
> that we are on an IB interface is doing so because IB requires extra
> management of the multicast group joins/leaves).

I'll adopt those helpers already been discussed, and they will be
implemented with the helpers from new mechanism
(eg, rdma_ib_mgmt) in next version.

> But, like I said, this
> is an all or nothing change, it isn't something we can ease into.

It's will be great if we can make it, let's see ;-)

Regards,
Michael Wang

>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
