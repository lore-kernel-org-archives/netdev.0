From: "David S. Miller" <davem@redhat.com>
Subject: Re: reasons for dev_alloc_skb +16?
Date: Wed, 09 Jul 2003 17:20:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709.172012.41656849.davem@redhat.com>
References: <20030709152553.GB15293@gtf.org>
	<20030709175355.422545b5.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030709175355.422545b5.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Wed, 9 Jul 2003 17:53:55 +0200
   
   But it's not clear it is still a good idea because it leads to cache line 
   misalignment of the beginning of the packet, forcing the card to do a
   costly Read-Modify-Write cycle.
   
Only "dumb cards" do that, smart ones rewind to the beginning of
the current cache line and ask for the whole thing instead of
pieces.

The +16 is actually needed to align the first hunk of the outgoing
packet so we can do a 16-byte aligned memcpy of the hard-header
cache as we build the packet.

Jeff, look at LL_RESERVED_SPACE() and the comment above it in
include/linux/netdevice.h
