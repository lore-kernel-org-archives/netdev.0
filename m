From: Rick Kennell <kennell@ecn.purdue.edu>
Subject: Re: [OT] Connection tracking for IPSec
Date: Wed, 20 Aug 2003 23:37:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061440621.16712.289.camel@k7.localnet>
References: <1061378568.668.9.camel@teapot.felipe-alfaro.com>
	 <23600000.1061383792@ijir>
	 <1061388988.3804.8.camel@teapot.felipe-alfaro.com>
	 <1710000.1061417560@ijir>
Reply-To: netdev@oss.sgi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>,
   LKML <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew McGregor <andrew@indranet.co.nz>
In-Reply-To: <1710000.1061417560@ijir>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-08-20 at 17:12, Andrew McGregor wrote:
> --On Wednesday, August 20, 2003 04:16:28 PM +0200 Felipe Alfaro Solana 
> <felipe_alfaro@linuxmail.org> wrote:
> > The problem here is that opening up protocols 50 and 51, makes *any*
> > IPSec-protected traffic to pass the firewall, but I still want that any
> > traffic (IPSec-protected or not) be applied the connection-track
> > filters. For normal (no IPSec) traffic, an incoming packet is only
> > accepted if it belongs to a connection that was initiated locally. For
> > IPSec traffic, I just want the same. I don't want any kind of
> > IPSec-protected traffic to be able to pass through the firewall, only
> > traffic that belongs to a connection that was initiated locally on the
> > machine receiving it.
> 
> It doesn't make sense for this configuration to fail in this way, I agree.
> 
> Essentially, the ESP and AH transforms should be a magic netfilter rule, so 
> you can insert them in a netfilter chain and do this sort of thing.  If 
> they aren't, we should at least have the input and output chains traversed 
> by packets both before and after the transforms.

I brought up the same thing in the netfilter and netfilter-dev lists
last month.  http://www.spinics.net/lists/netfilter/msg18030.html

I think there's no need for a special netfilter rule if the assumption
is made that an ESP packet reaching the "mangle" chain of the "INPUT"
table is definitely destined for a local process.  At that point, it
should be automatically unencapsulated so that its true protocol and
port numbers can be interrogated.  e.g. if we know an ESP packet is for
this machine, do the unencapsulation as early as possible.  Since
there's not yet a consensus on the behavior of things like NAT-based
forwarding of IPsec packets I think this is a safe assumption.  (But my
opinion generally doesn't count for much.)

If it's important to remember that the packet had been an ESP packet,
netfilter can be set up to mark it as such in the PREROUTING mangle
chain so that it can later be filtered appropriately.  This seems
similar to what I've read is done in FreeBSD:

http://www.bsdforums.org/forums/showthread.php?threadid=11725

> The issue exists, I'm convinced.  Dang, I'm going to run into it too one 
> day soon.  Another thing that needs looking at, in case noone else fixes it 
> first.

That's sort of what I thought too.  And, yeah, I'd be real happy if
someone else did it before I tried to.  8^)

-- 
Rick Kennell <kennell@ecn.purdue.edu>
Purdue University School of Electrical and Computer Engineering
