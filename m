From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Tue, 9 Jan 2007 09:10:45 +0100
Message-ID: <20070109081045.GA1703@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <459EB627.5040606@candelatech.com> <20070108065346.GA1665@ff.dom.local> <45A277E6.6000904@candelatech.com> <20070108100350.1187a3dc@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:42621 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751147AbXAIIIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 03:08:54 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070108100350.1187a3dc@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 08, 2007 at 10:03:50AM -0800, Stephen Hemminger wrote:
> On Mon, 08 Jan 2007 08:57:10 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> > Jarek Poplawski wrote:
> > > On Fri, Jan 05, 2007 at 12:33:43PM -0800, Ben Greear wrote:
> > > ...
> > >   
> > >> So, I do believe this was the problem we were hitting, and it seems fixed.
> > >>     
> > >
> > > Congratulations!
> > >
> > > But I can see one strange thing in vlan.c:
> > >
> > > /* Must be invoked with RCU read lock (no preempt) */
> > > static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
> > > ...
> > >  * Must be invoked with RCU read lock (no preempt)
> > >  */
> > > struct net_device *__find_vlan_dev(struct net_device *real_dev,
> > > ...
> > >
> > > But later in this file no sign of disabling preemption
> > > for these calls and for hlist_add_head_rcu and hlist_del_rcu.
> > >
> > > I can't imagine how this works?
> 
> Preempt is already disabled on the receive path.

I'm not sure you're talking about the same thing -
there is blocking possible inside register_vlan_dev
and unregister_vlan_dev, grp pointer is held during
this blocking - I've thought it's only possible in
sleepable RCU...

Jarek P.
