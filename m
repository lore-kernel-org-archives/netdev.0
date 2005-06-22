From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 23 Jun 2005 00:11:58 +0200
Message-ID: <20050622221158.GZ14251@wotan.suse.de>
References: <1119458226.6918.142.camel@localhost.localdomain> <200506221801.j5MI11xS021866@guinness.s2io.com> <20050622180654.GX14251@wotan.suse.de> <20050622.132241.21929037.davem@davemloft.net> <20050622211058.GY14251@wotan.suse.de> <42B9DDDA.5040405@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        leonid.grossman@neterion.com, hadi@cyberus.ca, becker@scyld.com,
        rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortel.com>
Content-Disposition: inline
In-Reply-To: <42B9DDDA.5040405@nortel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2005 at 03:53:30PM -0600, Chris Friesen wrote:
> Andi Kleen wrote:
> 
> >8 entries? That sounds very small. Is that an old Sparc or something? :)
> 
> The G5 has 8 prefetch streams.  Not an ancient cpu.

prefetch stream means a context of the auto prefetcher. 

It different from a load queue entry which is just a load of a cache line
which can be triggered by user instructions or the auto prefetcher. 
Each prefetch stream would consume a lot of them, so just for your 8 streams 
above you probably need a large two digit number or more.

I don't have exact numbers for the PPC970, but afaik its LS unit
has a very long queue. On POWER4 (which is a very similar CPU) we see 
a lot of races that don't happen on other platforms. That seems to be 
because it reorders writes every aggressively. I suppose this is true for
reads as well.

-Andi
