From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Mon, 20 Apr 2015 10:33:54 -0400
Message-ID: <20150420143354.GA4206@htj.duckdns.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <CAOS_Y6Q=1YwsL3wijnNSGmZh-xa8DXjp4PLc-hPGXGd3acTuZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Rob Landley <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOS_Y6Q=1YwsL3wijnNSGmZh-xa8DXjp4PLc-hPGXGd3acTuZA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Rob.

On Sun, Apr 19, 2015 at 02:25:09AM -0500, Rob Landley wrote:
> If you have two machines plugged into a hub, and that's _all_ that's
> plugged in, packets should never get dropped. This was the original
> use case of netconsole was that the sender and the receiver were
> plugged into the same router.

Development aid on local network hasn't been the only use case for a
very long time now.  I haven't seen too many large scale setups and
two of them were using netconsole as a way to collect kernel messages
cluster-wide and having issues with lost messages.  One was running it
over a separate lower speed network from the main one which they used
for most managerial tasks including deployment and packet losses
weren't that unusual.

The other is running on the same network but the log collector isn't
per-rack so the packets end up getting routed through congested parts
of the network again experiencing messages losses.

> So are you trying to program around a problem you've actually _seen_,
> or are you attempting to reinvent TCP/IP yet again based on top of UDP
> (Drink!) because of a purely theoretical issue?

At larger scale, the problem is very real.  Let's forget about the
reliability part.  The main thing is being able to identify message
sequences so that the receiver can put the message streams back
together.

That said, once that's there, whether the "reliability" part is done
with TCP doesn't make that much of difference as it'd still need to
put back the two message streams together, but again this doesn't
matter.  Let's just ignore this part.

> > printk already keeps log metadata which contains enough information to
> > make netconsole reliable.  This patchset does the followings.
> 
> Adds a giant amount of complexity without quite explaining why.

The only signficant complexity is on the receiver side and it doesn't
even have to be in the kernel.  CON_EXTENDED and emitting extended
messages are pretty straight-forward changes.

Thanks.

-- 
tejun
