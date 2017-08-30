From: "liujian (CE)" <liujian56@huawei.com>
Subject: RE: Question about ip_defrag
Date: Wed, 30 Aug 2017 01:52:34 +0000
Message-ID: <4F88C5DDA1E80143B232E89585ACE27D018F507F@DGGEMA502-MBX.china.huawei.com>
References: <4F88C5DDA1E80143B232E89585ACE27D018F07E2@DGGEMA502-MBX.china.huawei.com>
 <20170824155300.1e577dae@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F0AE1@DGGEMA502-MBX.china.huawei.com>
 <20170824205926.2c45e3a1@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F3157@DGGEMA502-MBX.china.huawei.com>
 <20170828140032.GB12926@breakpoint.cc>
 <4F88C5DDA1E80143B232E89585ACE27D018F4850@DGGEMA502-MBX.china.huawei.com>
 <20170829134635.GB9993@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:11823 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdH3Bwt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 21:52:49 -0400
In-Reply-To: <20170829134635.GB9993@breakpoint.cc>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




Best Regards,
liujian


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Florian Westphal
> Sent: Tuesday, August 29, 2017 9:47 PM
> To: liujian (CE)
> Cc: Florian Westphal; Jesper Dangaard Brouer; netdev@vger.kernel.org;
> Wangkefeng (Kevin); weiyongjun (A)
> Subject: Re: Question about ip_defrag
> 
> liujian (CE) <liujian56@huawei.com> wrote:
> 
> [ trimming cc list ]
> 
> > Now, I have not the real environment.
> > I use iperf generate fragment packets; and I always change NIC rx
> > irq's affinity cpu, to make sure frag_mem_limit reach to thresh.
> > my test machine, CPU num is 384.
> 
> Oh well, that explains it.
> 
> > > > +	if (frag_mem_limit(nf) > nf->low_thresh) {
> > > >  		inet_frag_schedule_worker(f);
> > > > +		update_frag_mem_limit(nf, SKB_TRUESIZE(1500) * 16);
> > > > +	}
> 
> You need to reduce this to a lower value.
> Your cpu count * batch_value needs to be less than low_thresh to avoid
> problems.
> 
> Wtih 384 cpus its close to 12 mbyte...
> 
> Perhaps do this:
> 
> update_frag_mem_limit(nf, 2 * 1024*1024 / NR_CPUS);
> 
> 
> However, I think its better to revert the percpu counter change and move back
> to a single atomic_t count.

Ok. 
Florian and Jesper, many thanks for this issue. 
