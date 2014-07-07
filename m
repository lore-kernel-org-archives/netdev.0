From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: RSS is not efficient when forwarding (ixgbe)
Date: Mon, 7 Jul 2014 16:33:24 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664685DCFE12@ORSMSX110.amr.corp.intel.com>
References: <20140703224408.GA2343@t520.home>
 <20140704193644.GB2343@t520.home>
 <CA+mtBx-dY2eoDzL-1K8F8Br224H+c4fzVtVPu9JmnjLdQKuAOg@mail.gmail.com>
 <20140707105523.GC2343@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Flavio Leitner <fbl@redhat.com>, Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64474 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291AbaGGQdj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 12:33:39 -0400
In-Reply-To: <20140707105523.GC2343@t520.home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 
> It's a router forwarding traffic from one interface to another, so I guess it's
> only the kernel. BTW, no firewall.
> 
> Flow Director needs to be enabled and I am using defaults.

Flow Director in ATR mode is on by default for ixgbe.  So like Tom mentioned the driver will create hash buckets for egress packets.  You could try disabling ATR and just use RSS.  Which would probably be the right thing to do any way since Flow Director isn't very useful for routing scenarios.  

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>

> 
> > > I have tried the same setup and test with another card (bnx2, 1GbE)
> > > and all queues got traffic by default though they were all assigned
> > > to CPU#0 (no irqbalance), so this is expected and makes me think
> > > this is specific to the ixgbe driver.
> > >
> > > Any ideas?
> > >
> > > Thanks,
> > > fbl
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org More majordomo
> > > info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org More majordomo
> info
> > at  http://vger.kernel.org/majordomo-info.html
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
