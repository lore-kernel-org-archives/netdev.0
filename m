From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] act_mirred: do not drop packets when fails to mirror
 it
Date: Wed, 15 Aug 2012 21:42:03 +0800
Message-ID: <502BA72B.6070205@redhat.com>
References: <20120815093756.22238.80872.stgit@amd-6168-8-1.englab.nay.redhat.com> <1345034141.20443.12.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: jhs@mojatatu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345034141.20443.12.camel@mojatatu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2012 08:35 PM, Jamal Hadi Salim wrote:
> On Wed, 2012-08-15 at 17:37 +0800, Jason Wang wrote:
>> We drop packet unconditionally when we fail to mirror it. This is not intended
>> in some cases.
> Hi Jason,
> Did you actually notice the behavior you described or were you going by
> the XXX comment I had in the code?
>
> cheers,
> jamal
Hi Jamal:

I met it actually through the following steps:

- start a kvm guest with tap and make it to be an interface of the bridge
- mirror the ingress traffic of the bridge to the tap
- terminate the qemu process, the tap device is then removed
- all packet goes to bridge would be dropped, so the network of guests 
in the same bridge would be broken

It's hard for the management to forcast the termination of the porcess 
and clean the mirroring before. The realistic way is to remove the 
mirroring after the termination of the process. So, if we drop the 
packets when the mirred device (tap) is removed, in the gap between the 
qemu termitnaion and disabling mirroring, the bridge ( and other VMs 
using the it) would not recevie any packet.

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
