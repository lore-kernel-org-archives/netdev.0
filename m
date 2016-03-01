From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] net/core: Add support for configuring VF GUIDs
Date: Tue, 1 Mar 2016 23:08:55 +0200
Message-ID: <CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w@mail.gmail.com>
References: <1456851143-138332-1-git-send-email-eli@mellanox.com>
	<1456851143-138332-2-git-send-email-eli@mellanox.com>
	<20160301173751.GA25176@obsidianresearch.com>
	<20160301174951.GA19366@x-vnc01.mtx.labs.mlnx>
	<20160301182516.GA12495@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160301182516.GA12495-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 1, 2016 at 8:25 PM, Jason Gunthorpe
<jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> On Tue, Mar 01, 2016 at 07:49:51PM +0200, Eli Cohen wrote:
>> On Tue, Mar 01, 2016 at 10:37:51AM -0700, Jason Gunthorpe wrote:
>> > > + return handle_infiniband_guid(dev, &ivt, IFLA_VF_IB_PORT_GUID);
>> >
>> > But is this emulation really necessary? It seems dangerous and
>> > continues the bad practice of assuming IFLA_VF_MAC is fixed to 6 bytes
>> > in size, and is not just LLADDR bytes. I'd rather see mac sets fail on
>> > IB.
>> >
>> struct ifla_vf_mac  already defines mac as 32 bytes but the idea here
>> is that applications that configure six byte Ethernet MACs to VFs will
>> continue to work without any change.
>
> In my view it is incorrect for an application to try and set a 6 byte
> mac on an *infiniband* interface, the kernel should refuse to do it.

As Eli wrote, there's a well defined way to extend MAC to GUID. With
that in hand, the idea here is to allow staged/evolved support for IB
Virtualization using un-touched provisioning systems which assign VMs
with 6-byte MACs along with the fully IB aware solution where the
upper level does provision IB GUIDs.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
