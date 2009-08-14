From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [net-next PATCH 05/12] net: Add ndo_fcoe_control to
 net_device_ops
Date: Fri, 14 Aug 2009 16:29:49 -0700
Message-ID: <7C88852EF6F99F4EB538472FCFEBE2223E29AA3F@orsmsx509.amr.corp.intel.com>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
	<20090814224239.1640.74924.stgit@localhost.localdomain>
 <20090814.161443.18892020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814.161443.18892020.davem@davemloft.net>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, August 14, 2009 4:15 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; linux-scsi@vger.kernel.org; gospo@redhat.com; Zou,
>Yi
>Subject: Re: [net-next PATCH 05/12] net: Add ndo_fcoe_control to
>net_device_ops
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Fri, 14 Aug 2009 15:42:39 -0700
>
>> From: Yi Zou <yi.zou@intel.com>
>>
>> Add ndo_fcoe_control to net_device_ops so the corresponding HW can
>initialize
>> itself for FCoE traffic or clean up after FCoE traffic is done. This is
>> expected to be called by the kernel FCoE stack upon receiving a request for
>> creating an FCoE instance on the corresponding netdev interface. When
>> implemented by the actual HW, the HW driver check the op code to perform
>> corresponding initialization or clean up for FCoE. The initialization
>normally
>> includes allocating extra queues for FCoE, setting corresponding HW
>registers
>> for FCoE, indicating FCoE offload features via netdev, etc. The clean-up
>would
>> include releasing the resources allocated for FCoE.
>>
>> Currently, there are two defined op codes as NETDEV_FCOE_DISABLE and
>_ENABLE,
>> for initialization and cleanup accordingly.
>>
>> Signed-off-by: Yi Zou <yi.zou@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
>And here is where I stop applying patches.  This is not the way
>to do this.
>
>Having a vague "_control" operation with command codes is almost
>as bad as ioctl().
>
>Instead, add explicit ->ndo_fcoe_enable() and ndo_fcoe_disable()
>operations.
>
>Any other "control" commands you would add would probably need
>parameters, and then this method would be a tangled web of
>misc parameter slots and an even more tangled web of semantics.
>
>Please resubmit the rest of this series once this issue is corrected.
>
>Thanks.
Thanks, I was kind of worried about the growing of fcoe related function
pointers there. I am thinking that if it may be better to move into a
fcoe_ops structure. If so, I will rework these patch and move them into
the fcoe_ops sturct in the updated set of patches. This will also make sense
as I am currently trying to add support for querying the nic for the Fiber
Channel WWN for the FCoE kernel stack (based on the SAN MAC address plus 2
more bytes as the IEEE extended address format) from the from the same ops
struct.

Thanks,
yi

