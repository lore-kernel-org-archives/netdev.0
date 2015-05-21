From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 04/12] IB/ipoib: Return IPoIB devices matching
 connection parameters
Date: Thu, 21 May 2015 08:33:53 +0300
Message-ID: <555D6E41.10606@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-5-git-send-email-haggaie@mellanox.com>
 <20150519235502.GB26634@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150519235502.GB26634-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20/05/2015 02:55, Jason Gunthorpe wrote:
> On Sun, May 17, 2015 at 08:51:00AM +0300, Haggai Eran wrote:
>> > From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> > 
>> > Implement the get_net_device_by_port_pkey_ip callback that returns network
>> > device to ib_core according to connection parameters. Check the ipoib
>> > device and iterate over all child devices to look for a match.
> Can you give a run down on how to actually set this up? Like what
> shell command do you execute?

Sure.

There are two methods to create new child interface for IPoIB.
For a specific P_Key, write the desired P_Key to the create_child sysfs
file:
# echo 0x8000 > /sys/class/net/ib0/create_child
This creates a new interface ib0.8000 operating with P_Key 0x8000.

To create a new child interface on the default P_Key, its possible to
use iproute:
# ip link add link ib0 name ib0.1 type ipoib

In order to create a new network namespace:
# ip netns add ns1

Then, you can assign the new netdev to the namespace:
# ip link set ib0.1 netns ns1

You can then set an IP address in the network namespace, and try some
RDMA CM applications:
# ip netns exec ns1 ip addr add dev ib0.1 192.168.0.1/24
# ip netns exec ns1 rdma_server

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
