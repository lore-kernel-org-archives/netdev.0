From: Carlos Carvalho <carlos@fisica.ufpr.br>
Subject: Re: RSS is not efficient when forwarding (ixgbe)
Date: Tue, 8 Jul 2014 14:09:13 -0300
Message-ID: <21436.9657.845209.575715@fisica.ufpr.br>
References: <20140703224408.GA2343@t520.home>
	<20140704193644.GB2343@t520.home>
	<CA+mtBx-dY2eoDzL-1K8F8Br224H+c4fzVtVPu9JmnjLdQKuAOg@mail.gmail.com>
	<20140707105523.GC2343@t520.home>
	<F6FB0E698C9B3143BDF729DF2228664685DCFE12@ORSMSX110.amr.corp.intel.com>
	<20140708002837.GS2346@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Skidmore\, Donald C" <donald.c.skidmore@intel.com>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fisica.ufpr.br ([200.17.209.129]:64867 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbaGHRQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 13:16:44 -0400
In-Reply-To: <20140708002837.GS2346@t520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flavio Leitner (fbl@redhat.com) wrote on 7 July 2014 21:28:
 >On Mon, Jul 07, 2014 at 04:33:24PM +0000, Skidmore, Donald C wrote:
 >> 
 >> 
 >> > 
 >> > It's a router forwarding traffic from one interface to another, so I guess it's
 >> > only the kernel. BTW, no firewall.
 >> > 
 >> > Flow Director needs to be enabled and I am using defaults.
 >> 
 >> Flow Director in ATR mode is on by default for ixgbe.  So like Tom mentioned the driver will create hash buckets for egress packets.  You could try disabling ATR and just use RSS.  Which would probably be the right thing to do any way since Flow Director isn't very useful for routing scenarios.  
 >
 >That was it.

We have a similar setup and similar problem. How do we disable ATR? I
tried to set ntuple off but this almost zeroed traffic. I also tried
to change rx-flow-hash but ethtool says it's not possible. The docs
say that one can disable ATR by setting AtrSampleRate to 0 but this
parameter doesn't exist in 3.14.10.

So, how do we disable ATR and keep RSS?
