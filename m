From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 11:53:14 -0800 (PST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030327.115314.121599027.davem@redhat.com>
References: <Pine.LNX.4.44.0303271120230.31459-100000@home.transmeta.com>
	<20030327.113933.123322481.davem@redhat.com>
	<1048794730.775.14.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@transmeta.com, dane@aiinet.com, shmulik.hen@intel.com,
	bonding-devel@lists.sourceforge.net,
	bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: rml@tech9.net
In-Reply-To: <1048794730.775.14.camel@localhost>
List-Id: netdev.vger.kernel.org

   From: Robert Love <rml@tech9.net>
   Date: 27 Mar 2003 14:52:11 -0500

   On Thu, 2003-03-27 at 14:39, David S. Miller wrote:
   
   > I hadn't considered this, good idea.  I'm trying this out right now.
   
   I hope it works.  I have a sinking feeling we call it some places that
   may have interrupts disabled...

Your sinking feeling was warranted.

Nearly every hw IRQ implementation invokes irq_exit() with
CPU interrupts off :-(  That has to be screwing with performance
as well.
