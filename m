From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Make xfrm subsystem optional
Date: Sun, 15 Jun 2003 10:08:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615080824.GA11398@wotan.suse.de>
References: <20030614101851.GA24170@wotan.suse.de> <20030614.042636.74749587.davem@redhat.com> <20030614183232.GB23546@wotan.suse.de> <20030614.200303.71094694.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030614.200303.71094694.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 14, 2003 at 08:03:03PM -0700, David S. Miller wrote:
>    From: Andi Kleen <ak@suse.de>
>    Date: Sat, 14 Jun 2003 20:32:32 +0200
> 
>    On Sat, Jun 14, 2003 at 04:26:36AM -0700, David S. Miller wrote:
>    >    From: Andi Kleen <ak@suse.de>
>    >    Date: Sat, 14 Jun 2003 12:18:51 +0200
>    >    
>    >    Allocating it at first lookup would be racy (would need a nasty
>    >    spinlock at least). It may be possible at first policy setup, but
>    >    it's not guaranteed you can still get two 32K continuous areas. You
>    >    could fall back to vmalloc I guess.
>    > 
>    > Andi, you're getting rediculious.  Add a xfrm_whatever_init() call
>    > and allocate the table there.
>    
>    Did you actually read what I wrote? Allocating on init is useless
>    from the bloat perspective because it's 100% equivalent to an BSS 
>    allocation.
>    
> If dynamic, you could allocate a "tiny" hash table or whatever
> on bootup and grow it as usage increases, much like we grow the
> FIB hashes dynamically.

I suspect dynamic growing at runtime would result in interesting SMP
locking issues (suspect - i haven't studied the xfrm locking in detail
yet) 

Also it has the same problem - 32K direct mapping allocation may not
work anymore during runtime.

I can take a look later if something else can be improved, but I'm
not very optimistic (the design of this thing is just not lightweight
neither in code nor data structures) 
Especially since you already vetoed the two best looking options.

It is just another inetpeer cache, a sleeping gigant waiting mostly 
unused for its great days ;)

-Andi
