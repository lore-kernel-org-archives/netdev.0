From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v9 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Fri, 3 Sep 2010 13:52:33 +0300
Message-ID: <20100903105233.GA32193@redhat.com>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
 <1281489804.3391.23.camel@localhost.localdomain>
 <1281490993.3391.25.camel@localhost.localdomain>
 <1281506460.3391.42.camel@localhost.localdomain>
 <1281509704.3391.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1281509704.3391.45.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 10, 2010 at 11:55:04PM -0700, Shirley Ma wrote:
> On Tue, 2010-08-10 at 23:01 -0700, Shirley Ma wrote:
> > On Tue, 2010-08-10 at 18:43 -0700, Shirley Ma wrote:
> > > > Also I found some vhost performance regression on the new
> > > > kernel with tuning. I used to get 9.4Gb/s, now I couldn't get it. 
> > > 
> > > I forgot to mention the kernel I used 2.6.36 one. And I found the
> > > native
> > > host BW is limited to 8.0Gb/s, so the regression might come from the
> > > device driver not vhost.
> > 
> > Something is very interesting, when binding ixgbe interrupts to cpu1,
> > and running netperf/netserver on cpu0, the native host to host
> > performance is still around 8.0Gb/s, however, the macvtap zero copy
> > result is 9.0Gb/s.
> > 
> > root@localhost ~]# netperf -H 192.168.10.74 -c -C -l60 -T0,0 -- -m 64K
> > TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.74 (192.168..
> > 10.74) port 0 AF_INET : cpu bind
> > Recv   Send    Send                          Utilization       Service Demand
> > Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> > Size   Size    Size     Time     Throughput  local    remote   local   remote
> > bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
> > 
> >  87380  16384  65536    60.00      9013.59   53.01    8.21     0.963   0.597
> > 
> > Below is perf top output:
> > 
> >               578.00  6.5% copy_user_generic_string   
> >               381.00  4.3% vmx_vcpu_run                
> >               250.00  2.8% schedule                    
> >               207.00  2.3% vhost_get_vq_desc           
> >               204.00  2.3% _raw_spin_lock_irqsave      
> >               197.00  2.2% translate_desc              
> >               193.00  2.2% memcpy_fromiovec            
> >               162.00  1.8% gup_pte_range   
> > 
> > We can compare your results with mine to see any difference.

Could you look at the guest as well?

> When binding vhost thread to cpu3, qemu I/O thread to cpu2, macvtap zero
> copy patch can get 9.4Gb/s. 
> 
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.74 (192.168.10.74) port 0 AF_INET : cpu bind
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
> 
>  87380  16384  65536    60.00      9408.19   55.69    8.45     0.970   0.589
> 
> Shirley

OTOH CPU utilization is up too.

-- 
MST
