From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Thu, 11 Jan 2007 08:24:28 +0100
Message-ID: <20070111072428.GA1672@ff.dom.local>
References: <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <459EB627.5040606@candelatech.com> <20070108065346.GA1665@ff.dom.local> <45A277E6.6000904@candelatech.com> <20070108100350.1187a3dc@freekitty> <20070109081045.GA1703@ff.dom.local> <20070110090411.GA1589@ff.dom.local> <20070110125048.GB2611@ff.dom.local> <20070110120123.52376578@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:46669 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965321AbXAKHWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 02:22:33 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070110120123.52376578@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 12:01:23PM -0800, Stephen Hemminger wrote:
...
> Don't rely on books too heavily, they can get out of date
> with a simple code change.

I've tried to find this in the code at the beginning
and got mislead by the path with PREEMPT_BKL.
I think the books are necessary to get general ideas
and I tried to check why would I get so wrong ideas.

> The path that I am talking about is the receive skb path. All data
> received goes through netif_receive_skb and that does rcu_read_lock().
> This is done so that receive protocol list can be used with RCU (lock
> free). Since receiving is a time critical path, we want to process
> without having to do any locked operations; locked operations cause a
> processor force a cache miss and are one of the main CPU overheads.
> RCU requires no locked operation, but does prevent preemption.

I again think we talk about different subjects. Maybe
it's because of this thread - but I don't talk about
Ben's original problem no more - it's a problem of
linux vlans.

Yesterday I did what I should do earlier - checked
this simple way, with printk, and now I have no doubts
it's a bug: if you add or remove vlan devices with
vconfig, register_vlan_device and unregister_vlan_dev
are called by ioctl and they use and change rcu
procetded data without preemption disabled so vlan
rcu hash lists could become corrupted or find results
could be wrong.

Regards,
Jarek P.
