From: Tom Talpey <tom-CLs1Zie5N5HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
Date: Tue, 31 Mar 2015 09:56:29 -0400
Message-ID: <551AA78D.4040502@talpey.com>
References: <551579CA.4030901@profitbricks.com> <55157B98.1060103@profitbricks.com> <20150327161319.GB28412@obsidianresearch.com> <20150327171631.GC27862@phlsvsds.ph.intel.com> <20150327172912.GA28901@obsidianresearch.com> <55196754.5010600@profitbricks.com> <20150330223528.GB27728@obsidianresearch.com> <551A4F24.6090405@profitbricks.com> <551A82D3.70806@talpey.com> <551A87D3.2070306@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
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
	Alex Estrin <alex.estrin@
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <551A87D3.2070306-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/31/2015 7:41 AM, Michael Wang wrote:
> Hi, Tom
>
> Thanks for the comments :-)
>
> On 03/31/2015 01:19 PM, Tom Talpey wrote:

[oops - repeating my reply with full cc's]

>> [snip]
>>
>>>
>>> Actually I'm thinking about Doug's idea to use rdma_transport_is_XX()
>>> instead of the current basic helper, thus may be use rdma_transport_is_iwarp()
>>> in here could be better, since it's actually a feature of iwarp tech
>>> that RDMA Read only support one scatter-gather entry.
>>
>> No, you should expose an attribute to surface the maximum length of
>> the remote gather list, which varies by adapter as well as protocol.
>> The fact that iWARP is different from IB is not relevant, and conflates
>> unrelated properties.
>
> To be confirmed, so your point is that the max-read-sges will be different
> even the transport is the same IWRAP, and that depends on the capability
> of adapter, correct?

Yes, in fact the iWARP protocol does not preclude multiple read SGEs,
even though most iWARP implementations have chosen to support just one.

Even for multi-SGE-capable adapters, there is a limit of SGL size, based
on the adapter's work request format and other factors. So my argument
is that upper layers can and should query that, not make a blanket
decision based on protocol type.

>
> I currently only find this one place where infer max-read-sges from
> transport type, it looks more like a special case to me rather than a generic
> method we could exposed... and also  not very related with IB management
> helper concept IMHO.

It is most certainly not a special case, but you could decide to
introduce it in many ways. I'm not commenting on that.

My main concern is that you do not introduce a new and clumsy "is iWARP"
rule as an adapter-specific API requirement to expose the RDMA Read SGE
behavior. That's what your initial message seemed to imply?


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
