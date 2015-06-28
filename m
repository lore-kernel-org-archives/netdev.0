From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Sun, 28 Jun 2015 23:19:22 +0300
Message-ID: <CAJ3xEMj_3+p9CGH8bkF26E9X0KGQdTr14S-vACS7zKcPPO6pQA@mail.gmail.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
	<CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
	<0b2eff60824ac7b7d3a672da9be9bf99@imap.linux.ibm.com>
	<CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
	<3df94e04daebca29c94b6d32fb372177@imap.linux.ibm.com>
	<CALx6S35-GKW+hgn-9Y5a87hETfetKuusALFUDZ5vzwrtQSiypA@mail.gmail.com>
	<3036c2aaa52dc2817e674a77b5eac24d@imap.linux.ibm.com>
	<CALx6S37+es-QD-_41O4cc59_oEX2UeeibZgjd8uOvTcPMHO+nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	pradeeps@linux.vnet.ibm.com, J Kidambi <jkidambi@us.ibm.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:34021 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbbF1UTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 16:19:23 -0400
Received: by obbkm3 with SMTP id km3so93565668obb.1
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2015 13:19:22 -0700 (PDT)
In-Reply-To: <CALx6S37+es-QD-_41O4cc59_oEX2UeeibZgjd8uOvTcPMHO+nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2015 at 10:59 PM, Tom Herbert <tom@herbertland.com> wrote:
[...]
> Looks like GRO was never implemented for vxlan tunnels. The driver is
> simply calling netif_rx instead of using the GRO cells infrastructure.
> geneve is doing the same thing. For other tunnels which are used in
> foo-over-udp (GRE, IPIP, SIT) ip_tunnel_rcv is called which in turn
> calls gro_cells_receive.

Tom,

Since v3.14, when a tunneled (say VXLAN/GRE) packets are received on
the physical interface, they go through GRO aggregation before being
delivered up to the tunnel "device" (e.g either vxlan/gre netdevice or
OVS vxlan/gre vport) -- so in that respect, can you elaborate a little
further why we want to GRO them again?

Or.
