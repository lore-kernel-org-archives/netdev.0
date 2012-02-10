From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Thu, 09 Feb 2012 18:14:46 -0800
Message-ID: <4F347D96.2020806@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>  <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>  <4F34042F.6090806@intel.com>  <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>  <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: jhs@mojatatu.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1328821894.2089.3.camel@mojatatu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/9/2012 1:11 PM, jamal wrote:
> On Thu, 2012-02-09 at 09:52 -0800, John Fastabend wrote:
> 
>>>> By netlink_notifier do you mean adding a notifier_block and using atomic_notifier_call_chain()
>>>> probably in rtnl_notify()? Then drivers could register with the notifier chain with
>>>> atomic_notifier_chain_register() and receive the events correctly. Or did I miss
>>>> some notifier chain that already exists?
>>>
>>> Yes. that is what I mean. The callbacks you need may or may not already be present.
> 
> I'll go one step further.
> This stuff shouldnt be in the kernel at all. 
> The disadvantage is you need a user space app to update the hardware.
> i.e, the same mechanism should be usable for either a switch embedded
> in a NIC or a standalone hardware switch (with/out the s/ware bridge 
> presence)
> 
> cheers,
> jamal
> 

Hi Jamal,

The user space app in this case would listen for FDB updates to the SW
bridge and then mirror them at the embedded NIC. In this case it seems
easier to just add a notifier chain and let the kernel keep these in
sync. Otherwise we need a daemon in user space to replicate these.

On the other hand if you could make the same RTM_NEWNEIGH, RTM_DELNEIGH,
and RTM_GETNEIGH work for the bridge, embedded bridge, and macvlan you
would have one common interface to drive these. But the bridge already
has this protocol/msgtype so that would require either some demux or
new protocol/msgtype pairs to be created. 

Let me think on it. I'm tempted by the simplicity of adding notifier
hooks though.

.John


