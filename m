From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Mon, 8 Jan 2007 10:03:50 -0800
Message-ID: <20070108100350.1187a3dc@freekitty>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com>
	<E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
	<20070104.123333.91315611.davem@davemloft.net>
	<459EB627.5040606@candelatech.com>
	<20070108065346.GA1665@ff.dom.local>
	<45A277E6.6000904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60016 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422697AbXAHSHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 13:07:18 -0500
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <45A277E6.6000904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 Jan 2007 08:57:10 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Jarek Poplawski wrote:
> > On Fri, Jan 05, 2007 at 12:33:43PM -0800, Ben Greear wrote:
> > ...
> >   
> >> So, I do believe this was the problem we were hitting, and it seems fixed.
> >>     
> >
> > Congratulations!
> >
> > But I can see one strange thing in vlan.c:
> >
> > /* Must be invoked with RCU read lock (no preempt) */
> > static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
> > ...
> >  * Must be invoked with RCU read lock (no preempt)
> >  */
> > struct net_device *__find_vlan_dev(struct net_device *real_dev,
> > ...
> >
> > But later in this file no sign of disabling preemption
> > for these calls and for hlist_add_head_rcu and hlist_del_rcu.
> >
> > I can't imagine how this works?

Preempt is already disabled on the receive path.

> >   
> Perhaps...I didn't RCU-ify VLANs, but I can take a look.
> 
> For the record, the soft lockup was using MAC-VLANs, not 802.1Q VLANs, 
> so it wouldn't
> have been affected by bugs in VLANs one way or the other.
> 
> Ben
> 
> > Jarek P. 
> >   
> 
> 


-- 
Stephen Hemminger <shemminger@osdl.org>
