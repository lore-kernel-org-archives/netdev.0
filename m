From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 28 May 2015 19:21:11 +0300
Message-ID: <55674077.5040707@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	 <1432647280.28905.107.camel@redhat.com> <55671309.6080303@mellanox.com>
 <1432822057.114391.26.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432822057.114391.26.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/28/2015 5:07 PM, Doug Ledford wrote:
> You would think that, but sometimes important information comes from
> totally different places.  See mine and Jason's comments back and forth
> in the SRIOV thread started by Or.
>
> Long story short:
>
> ip link add dev ib0 name ib0.1 type ipoib
>
> is totally broken on at least all Red Hat OSes.  It will require
> reworking of the network scripts and NetworkManager assumptions to make
> it work.  It will also break DHCP on the interface as pkey/guid are the
> only items that uniquely identify DHCP clients.  The net result of our
> talks was that it is likely that each interface on the same pkey will
> require an alias GUID per child interface in order to keep things workable.
>

Doug,

Just to make sure we're on the same page, you're saying that the IPoIB 
DHCP scheme (client + server) used on RH product uses Client-ID which is 
eight byte long or 20 byte long the four upper bytes masked out (which 
of them?) and hence is broken when multiple entities use the same ID.

Anything else except for that (you said "reworking of the network 
scripts and NetworkManager assumptions to make it work")??

OTOH we realized that the implementation for same PKEY IPoIB childs 
which exist for a while is broken with the RH DHCP scheme and should be 
enhanced.   OTOH these childs can serve as nice building blocks for 
IPoIB containers or virtio-IPoIB scheme.

Note that out of the eleven patches that make the series, only ONE 
relates directly to IPoIB, the rest are either applicable to all the 
transport supported by the RDMA stack, or to IPoIB + RoCE.

Under some assumptions and changes people can test it with DHCP scheme 
different from RH or with non-DHCP based IP address assignment scheme.

So we have a very nice effort and work done by developers, to bring RDMA 
into containers, accompanied by reviewers providing lots of their brain 
power to make it robust.

I don't see why we should stop the whole RDMA containers support train 
just b/c we found out the IPoIB DHCP bug which was there for few years 
before this effort started.

How about let this series to go after the rest of the reviewers comments 
are addressed, s.t under IPoIB it will work on small set of 
environments, while with macvlan based RoCE support to be introduced 
later it will work on wider set of environments.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
