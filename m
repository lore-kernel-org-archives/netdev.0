From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the RDMA-CM
Date: Wed, 3 Jun 2015 22:05:34 +0300
Message-ID: <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	<1432647280.28905.107.camel@redhat.com>
	<55671309.6080303@mellanox.com>
	<1432822057.114391.26.camel@redhat.com>
	<55674077.5040707@mellanox.com>
	<20150528174337.GA10448@obsidianresearch.com>
	<1432837360.114391.35.camel@redhat.com>
	<CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
	<1432850150.114391.56.camel@redhat.com>
	<556ED0D5.8010502@mellanox.com>
	<20150603161447.GC12073@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150603161447.GC12073-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 3, 2015 at 7:14 PM, Jason Gunthorpe
<jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> On Wed, Jun 03, 2015 at 01:03:01PM +0300, Haggai Eran wrote:
>> > Then I'm inclined to say that we should map for namespaces using device,
>> > port, guid/gid, pkey.  And in this situation, since a unique guid/gid on
>> > any given pkey maps to a unique dhcp identifier and a unique ipv6
>> > lladdr, this becomes freely interchangeable with device, port, pkey,
>> > address mappings that this patchset was built around.
>>
>> What if we change the namespaces patches to map (device, port, GID,
>> P_Key, IP) to netdev / namespace? That is, to use both the GID and the
>> IP address.
>
> As I keep saying, you are not supposed to use the IP address as a key
> to find the netdev, that is the wrong way to use the Linux netdev
> model.
>
> Requiring unique GID/PKey allows the implementation to avoid this
> wrongness, which would be simplifying and more correct.
>
> That is the appeal to blocking this scenario when children are created.

Jason,

The IPoIB RTNL childs were added around release 3.6/7 of the upstream
kernel and are part of the kernel UAPI. They are perfectly used in
bunch of schemes:

1.  when static IP address assignment is used

2. under PV scheme, when the guest has para-virtual Eth NIC and the
host does routing between the back-end (e.g tap or alike) and  the
IPoIB child. Or when the host does tunneling (vxlan) and alike and
sends down the encapsulated packet through a host IP address assigned
to the IPoIB child

3. etc few more

Indeed the DHCP story isn't working there and to get DHCP work
something has to be done. But this issue can't serve for blocking the
existing UAPI and introduce regression to working systems.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
