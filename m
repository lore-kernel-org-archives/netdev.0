From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v4 0/8] Managing the forwarding database(FDB)
Date: Thu, 03 May 2012 12:38:13 -0700
Message-ID: <4FA2DEA5.6050802@intel.com>
References: <20120415163905.14091.30491.stgit@jf-dev1-dcblab> <20120415.130637.2258594023349277277.davem@davemloft.net> <20120502150830.GA2976@redhat.com> <4FA1ACA1.2080808@intel.com> <4FA1C50C.7010405@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, shemminger@vyatta.com,
	bhutchings@solarflare.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>,
	Roopa Prabhu <roopa.prabhu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18597 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755879Ab2ECTiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 15:38:13 -0400
In-Reply-To: <4FA1C50C.7010405@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2012 4:36 PM, Sridhar Samudrala wrote:
> On 5/2/2012 2:52 PM, John Fastabend wrote:
>> On 5/2/2012 8:08 AM, Michael S. Tsirkin wrote:
>>> On Sun, Apr 15, 2012 at 01:06:37PM -0400, David Miller wrote:
>>>> From: John Fastabend<john.r.fastabend@intel.com>
>>>> Date: Sun, 15 Apr 2012 09:43:51 -0700
>>>>
>>>>> The following series is a submission for net-next to allow
>>>>> embedded switches and other stacked devices other then the
>>>>> Linux bridge to manage a forwarding database.
>>>>>
>>>>> Previously discussed here,
>>>>>
>>>>> http://lists.openwall.net/netdev/2012/03/19/26
>>>>>
>>>>> v4: propagate return codes correctly for ndo_dflt_Fdb_dump()
>>>>>
>>>>> v3: resolve the macvlan patch 8/8 to fix a dev_set_promiscuity()
>>>>>      error and add the flags field to change and get link routines.
>>>>>
>>>>> v2: addressed feedback from Ben Hutchings resolving a typo in the
>>>>>      multicast add/del routines and improving the error handling
>>>>>      when both NTF_SELF and NTF_MASTER are set.
>>>>>
>>>>> I've tested this with 'br' tool published by Stephen Hemminger
>>>>> soon to be renamed 'bridge' I believe and various traffic
>>>>> generators mostly pktgen, ping, and netperf.
>>>> All applied, if we need any more tweaks we can just add them
>>>> on top of this work.
>>>>
>>>> Thanks John.
>>> John, do you plan to update kvm userspace to use this interface?
>>>
>> No immediate plans. I would really appreciate it if you or one
>> of the IBM developers working in this space took it on. Of course
>> if no one steps up I guess I can eventually get at it but it will
>> be sometime. For now I've been doing this manually with the bridge
>> tool yet to be published.
>>
>>
> Does this mean that when we add an interface to a bridge, it need not be put in promiscuous mode and
> add/delete fdb entries dynamically?

The net/bridge will automatically put the interface in promisc mode
when the device is attached. We do need to add/delete fdb entries
though to allow forwarding packets from the virtual function and
any emulated devices e.g. tap devices on the bridge.

Currently I am doing this by manually running a tool Stephen created.
My hope would be to integrate this with KVM so that when I setup my
VM with an emulated device and have SR-IOV enabled perhaps for direct
assign use case qemu/libvirt also adds the VM address to the embedded
switch FDB.

> Or are we talking only about VMs attached to macvtap?
> 

The macvlan bridge calls dev_uc_add and dev_uc_sync so in this case
we shouldn't need to explicitly add entries to the embedded bridge
on the physical function.

> Thanks
> Sridhar
> 
