From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/2] fixes to arp_notify for virtual machine migration
 use case
Date: Wed, 26 May 2010 11:08:12 +0100
Message-ID: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
References: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
	 <20100523.233722.232536798.davem@davemloft.net>
	 <1274779201.24218.7164.camel@zakaz.uk.xensource.com>
	 <20100525.230822.71096271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"stable@kernel.org" <stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:52825 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584Ab0EZKIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 06:08:16 -0400
In-Reply-To: <20100525.230822.71096271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-26 at 07:08 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Tue, 25 May 2010 10:20:01 +0100
> 
> > Anyway, assuming the fact that arp_notify is disabled by default hasn't
> > changed your mind, would adding NETDEV_NOTIFY_PEERS triggered by
> > netif_notify_peers() be appropriate or would it be preferable to simply
> > add netif_notify_peers() which generates the existing NETDEV_CHANGEADDR?
> 
> A seperate NETDEV_NOTIFY_PEERS seems the best idea to me.
> 
> > I don't think there's any need for a new sysctl so I'll gate the new
> > option on the existing arp_notify one.
> 
> Yep, sounds good.

The following changes since commit e40152ee1e1c7a63f4777791863215e3faa37a86:
  Linus Torvalds (1):
        Linus 2.6.34

are available in the git repository at:

  git://xenbits.xensource.com/people/ianc/linux-2.6.git for-netdev/fixes

Ian Campbell (3):
      arp_notify: document that a gratuitous ARP request is sent when this option is enabled
      arp_notify: allow drivers to explicitly request a notification event.
      xen: netfront: explicitly generate arp_notify event after migration.

 Documentation/networking/ip-sysctl.txt |    2 +-
 drivers/net/xen-netfront.c             |    1 +
 include/linux/netdevice.h              |    2 ++
 include/linux/notifier.h               |    1 +
 net/ipv4/devinet.c                     |    1 +
 net/sched/sch_generic.c                |   18 ++++++++++++++++++
 6 files changed, 24 insertions(+), 1 deletions(-)


