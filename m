From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 08 Sep 2011 20:00:53 -0700
Message-ID: <CA8ECF75.33BFF%roprabhu@cisco.com>
References: <20110908193332.GA2476@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, <netdev@vger.kernel.org>,
	<dragos.tatulea@gmail.com>, <arnd@arndb.de>, <dwang2@cisco.com>,
	<benve@cisco.com>, <kaber@trash.net>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <mchan@broadcom.com>,
	<kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110908193332.GA2476@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 9/8/11 12:33 PM, "Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, Sep 08, 2011 at 12:23:56PM -0700, Roopa Prabhu wrote:
>>> 
>>> I think the main usecase for passthru mode is to assign a SR-IOV VF to
>>> a single guest.
>>> 
>> Yes and for the passthru usecase this patch should be enough to enable
>> filtering in hw (eventually like I indicated before I need to fix vlan
>> filtering too).
> 
> So with filtering in hw, and in sriov VF case, VFs
> actually share a filtering table. How will that
> be partitioned?

AFAIK, though it might maintain a single filter table space in hw, hw does
know which filter belongs to which VF. And the OS driver does not need to do
anything special. The VF driver exposes a VF netdev. And any uc/mc addresses
registered with a VF netdev are registered with the hw by the driver. And hw
will filter and send only pkts that the VF has expressed interest in.

No special filter partitioning in hw is required.

Thanks,
Roopa

