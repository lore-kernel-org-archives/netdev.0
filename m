From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Wed, 3 Jun 2015 13:53:25 -0600
Message-ID: <20150603195325.GC7902@obsidianresearch.com>
References: <55671309.6080303@mellanox.com>
 <1432822057.114391.26.camel@redhat.com>
 <55674077.5040707@mellanox.com>
 <20150528174337.GA10448@obsidianresearch.com>
 <1432837360.114391.35.camel@redhat.com>
 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com>
 <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:52610 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbbFCTx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 15:53:29 -0400
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 10:05:34PM +0300, Or Gerlitz wrote:

> Indeed the DHCP story isn't working there and to get DHCP work
> something has to be done. But this issue can't serve for blocking the
> existing UAPI and introduce regression to working systems.

It is not DHCP that concerns me, it is the fact we can't combine net
namespaces, RDMA-CM and duplicate GUID IPoIB children together without
adding hacks to the kernel. Searching netdevs by IP is a hack.

I'm mostly fine with it as an optional capability, similar to macvlan,
I just don't see how to cleanly integrate it with RDMA CM and
namespaces. And I don't see what RDMA CM is supposed to do when
it hits this case.

So, any ideas that don't involve the searching for IP hack??

[And yes, as discussed with Haggie, it is not the worst hack in the
 world, and maybe we can live with it, but lets understand the trade
 offs carefully]

Also, now that this has been brought up, I think you need to make a
patch to fix the IPv6 SLAAC breakage this caused. It looks trivial to
modify addrconf_ifid_infiniband to return error if the IPoIB child is
sharing a guid. It was not good at all to push the child patches
forward to 3.6/3.7 if you knew that IPv6 SLAAC was broken by them.

Jason
