From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 0/4] Shared vhost design
Date: Tue, 28 Jul 2015 00:07:19 +0300
Message-ID: <20150728000221-mutt-send-email-mst@redhat.com>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
 <OF451FED84.3040AFD2-ONC2257E8C.0043F908-C2257E8C.00446592@il.ibm.com>
 <jpgmvyh9ybg.fsf@linux.bootlegged.copy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eyal Moscovici <EYALMO@il.ibm.com>, cgroups@vger.kernel.org,
	jasowang@redhat.com, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Razya Ladelsky <RAZYA@il.ibm.com>
To: Bandan Das <bsd@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <jpgmvyh9ybg.fsf@linux.bootlegged.copy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2015 at 03:48:19PM -0400, Bandan Das wrote:
> Eyal Moscovici <EYALMO@il.ibm.com> writes:
> 
> > Hi, 
> >
> > The test showed the same relative numbers as we got in our internal 
> > testing. I was wondering about the configuration in regards to NUMA. From
> Thanks for confirming.
> 
> > our testing we saw that if the VMs are spread across 2 NUMA nodes then 
> > having a shared vhost thread per node performs better then having the two 
> > threads in the same core.
> 
> IIUC, this is similar to my test setup and observations i.e 
> > 14*                                               1173.8  1216.9
> 
> In this case, there's a shared vhost thread on CPU 14 for numa node 0
> and another on CPU 15 for numa node 1. Guests running on CPUs 0,2,4,6,8,10,12
> are serviced by vhost-0 that runs on CPU 14 and guests running on CPUs 1,3,5,7,9,11,13
> get serviced by vhost-1 (Numa node 1). I tried some other configurations but
> this configuration gave me the best results.
> 
> 
> Eyal, I think it makes sense to add polling on top of these patches and
> get numbers for them too. Thoughts ?
> 
> Bandan

So simple polling by vhost is kind of ok for some guests, but I think to
really make it work for a reasonably wide selection of guests/workloads
you need to combine it with 1. polling the NIC - it makes no sense to me
to only poll one side of the equation; and probably 2. - polling in
guest.
