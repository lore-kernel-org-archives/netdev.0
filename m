From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
 support for passthru mode
Date: Wed, 19 Oct 2011 15:30:18 -0700
Message-ID: <CAC49D8A.374FB%roprabhu@cisco.com>
References: <43F901BD926A4E43B106BF17856F075501A177719C@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F075501A177719C@orsmsx508.amr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 10/19/11 2:06 PM, "Rose, Gregory V" <gregory.v.rose@intel.com> wrote:

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Roopa Prabhu
>> Sent: Tuesday, October 18, 2011 11:26 PM
>> To: netdev@vger.kernel.org
>> Cc: sri@us.ibm.com; dragos.tatulea@gmail.com; arnd@arndb.de;
>> kvm@vger.kernel.org; mst@redhat.com; davem@davemloft.net;
>> mchan@broadcom.com; dwang2@cisco.com; shemminger@vyatta.com;
>> eric.dumazet@gmail.com; kaber@trash.net; benve@cisco.com
>> Subject: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
>> support for passthru mode
>>  
> 
> [snip...]
> 
>> 
>> 
>> Note: The choice of rtnl_link_ops was because I saw the use case for
>> this in virtual devices that need  to do filtering in sw like macvlan
>> and tun. Hw devices usually have filtering in hw with netdev->uc and
>> mc lists to indicate active filters. But I can move from rtnl_link_ops
>> to netdev_ops if that is the preferred way to go and if there is a
>> need to support this interface on all kinds of interfaces.
>> Please suggest.
> 
> I'm still digesting the rest of the RFC patches but I did want to quickly jump
> in and push for adding this support in netdev_ops.  I would like to see these
> features available in more devices than just macvtap and macvlan.  I can
> conceive
> of use cases for multiple HW MAC and VLAN filters for a VF device that isn't
> owned by a macvlan/macvtap interface and only has netdev_ops support.  In this
> case it would be necessary to program the filters directly to the VF device
> interface or PF interface (or lowerdev as you refer to it) instead of going
> through macvlan/macvtap.
> 
> This work dovetails nicely with some work I've been doing and I'd be very
> interested
> in helping move this forward if we could work out the details that would allow
> support
> of the features we (and the community) require.

Great. Thanks. I will definitely be interested to get this patch working for
any other use case you have.

Moving the ops to netdev should be trivial. You probably want the ops to
work on the VF via the PF, like the existing ndo_set_vf_mac etc.
Yes, lets work out the details and I can move this to netdev->ops. Let me
know.

Thanks,
Roopa


