From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 03:13:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.031341.77044985.davem@redhat.com>
References: <20030609094734.GD2728@wotan.suse.de>
	<20030609.030334.02284330.davem@redhat.com>
	<20030609101302.GA9643@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030609101302.GA9643@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Mon, 9 Jun 2003 12:13:02 +0200

   On Mon, Jun 09, 2003 at 03:03:34AM -0700, David S. Miller wrote:
   > True, but the real bug is that we're initializing any of this
   > crap here at all.  Right now we write over the same cachelines
   > 3 or so times.  It should really just happen once.
   
   It's unlikely to be the reason for the profile hit on a modern x86.
   They are all really fast at reading/writing L1. 
   
It's store buffer compression that's being messed up.  I've seen this
on just about any processor.

This is also why the net/core/skbuff.c initialization hacks are so
effective as well.

Trust me, this has every symptom of excess store buffer traffic :)
