From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Fri, 09 Sep 2011 09:21:51 -0700
Message-ID: <CA8F8B2F.33CF2%roprabhu@cisco.com>
References: <4E699556.6050809@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, <netdev@vger.kernel.org>,
	<dragos.tatulea@gmail.com>, <arnd@arndb.de>, <dwang2@cisco.com>,
	<benve@cisco.com>, <kaber@trash.net>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <mchan@broadcom.com>,
	<kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4E699556.6050809@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 9/8/11 9:25 PM, "Sridhar Samudrala" <sri@us.ibm.com> wrote:

> On 9/8/2011 8:00 PM, Roopa Prabhu wrote:
>> 
>> 
>> On 9/8/11 12:33 PM, "Michael S. Tsirkin"<mst@redhat.com>  wrote:
>> 
>>> On Thu, Sep 08, 2011 at 12:23:56PM -0700, Roopa Prabhu wrote:
>>>>> I think the main usecase for passthru mode is to assign a SR-IOV VF to
>>>>> a single guest.
>>>>> 
>>>> Yes and for the passthru usecase this patch should be enough to enable
>>>> filtering in hw (eventually like I indicated before I need to fix vlan
>>>> filtering too).
>>> So with filtering in hw, and in sriov VF case, VFs
>>> actually share a filtering table. How will that
>>> be partitioned?
>> AFAIK, though it might maintain a single filter table space in hw, hw does
>> know which filter belongs to which VF. And the OS driver does not need to do
>> anything special. The VF driver exposes a VF netdev. And any uc/mc addresses
>> registered with a VF netdev are registered with the hw by the driver. And hw
>> will filter and send only pkts that the VF has expressed interest in.
> Does your NIC & driver support adding multiple mac addresses to a VF?
> I have tried a few other SR-IOV NICs sometime back and they didn't
> support this feature.

Yes our nic does. I thought Intel's also does (see ixgbevf_set_rx_mode).
Though I have not really tried using it on an Intel card. I think most cards
should at the least support multicast filters.

If the lower dev does not support unicast filtering, dev_uc_add(lowerdev,..)
puts the lower dev in promiscous mode. Though..i think I can chcek this
before hand in macvlan_open and put the lowerdev in promiscuous mode if it
does not support filtering.

> 
> Currently, we don't have an interface to add multiple mac addresses to a
> netdev other than an
> indirect way of creating a macvlan /if on top of it.

Yes I think so. I have been using only macvlan to test.

Thanks,
Roopa

