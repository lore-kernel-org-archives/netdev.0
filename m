From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make xfrm subsystem optional
Date: Sat, 14 Jun 2003 20:03:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614.200303.71094694.davem@redhat.com>
References: <20030614101851.GA24170@wotan.suse.de>
	<20030614.042636.74749587.davem@redhat.com>
	<20030614183232.GB23546@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030614183232.GB23546@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Sat, 14 Jun 2003 20:32:32 +0200

   On Sat, Jun 14, 2003 at 04:26:36AM -0700, David S. Miller wrote:
   >    From: Andi Kleen <ak@suse.de>
   >    Date: Sat, 14 Jun 2003 12:18:51 +0200
   >    
   >    Allocating it at first lookup would be racy (would need a nasty
   >    spinlock at least). It may be possible at first policy setup, but
   >    it's not guaranteed you can still get two 32K continuous areas. You
   >    could fall back to vmalloc I guess.
   > 
   > Andi, you're getting rediculious.  Add a xfrm_whatever_init() call
   > and allocate the table there.
   
   Did you actually read what I wrote? Allocating on init is useless
   from the bloat perspective because it's 100% equivalent to an BSS 
   allocation.
   
If dynamic, you could allocate a "tiny" hash table or whatever
on bootup and grow it as usage increases, much like we grow the
FIB hashes dynamically.
