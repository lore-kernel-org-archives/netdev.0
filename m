From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Wed, 3 Jun 2015 10:14:47 -0600
Message-ID: <20150603161447.GC12073@obsidianresearch.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:42027 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754831AbbFCQOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 12:14:52 -0400
Content-Disposition: inline
In-Reply-To: <556ED0D5.8010502@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 01:03:01PM +0300, Haggai Eran wrote:
> > Then I'm inclined to say that we should map for namespaces using device,
> > port, guid/gid, pkey.  And in this situation, since a unique guid/gid on
> > any given pkey maps to a unique dhcp identifier and a unique ipv6
> > lladdr, this becomes freely interchangeable with device, port, pkey,
> > address mappings that this patchset was built around.
> 
> What if we change the namespaces patches to map (device, port, GID,
> P_Key, IP) to netdev / namespace? That is, to use both the GID and the
> IP address.

As I keep saying, you are not supposed to use the IP address as a key
to find the netdev, that is the wrong way to use the Linux netdev
model.

Requiring unique GID/PKey allows the implementation to avoid this
wrongness, which would be simplifying and more correct.

That is the appeal to blocking this scenario when children are created.

Jason
