From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other macvlan devices
Date: Thu, 19 Nov 2009 12:44:43 +0100
Message-ID: <200911191244.43916.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <200911182332.56309.arnd@arndb.de> <m1bpiz8k1x.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751872AbZKSLrB@vger.kernel.org>
In-Reply-To: <m1bpiz8k1x.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 November 2009, Eric W. Biederman wrote:
> > It seems that we should never drop dst then. We either forward the frame to
> > netif_rx or to dev_queue_xmit, and from how I read it now, we want to keep
> > the dst in both cases.
> 
> When we loop back on our selves we certainly need to have dst clear because
> we don't know how to cache routes through multiple network namespaces.

Ah, right. So should I add the explicit dst_drop to the new dev_forward_skb()
then? The veth driver doesn't need it, but it also looks like it won't hurt.

	Arnd <><
