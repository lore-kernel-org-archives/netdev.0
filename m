From: jamal <hadi@cyberus.ca>
Subject: Re: af_packet & CHECKSUM_HW
Date: 19 Nov 2003 10:01:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069254105.1025.26.camel@jzny.localdomain>
References: <20031115024434.GA12276@gondor.apana.org.au>
	 <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com>
	 <20031116205146.GA8477@gondor.apana.org.au>
	 <20031117194452.GB18448@vana.vc.cvut.cz>
	 <20031117123047.55377d3a.davem@redhat.com>
	 <20031118132137.GA23732@vana.vc.cvut.cz>
	 <20031118174612.48c0854e.davem@redhat.com>
	 <20031119123535.GA11108@vana.vc.cvut.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, herbert@gondor.apana.org.au,
        jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20031119123535.GA11108@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-11-19 at 07:35, Petr Vandrovec wrote:

> I'm not sure that we should run skb_checksum() on the packet. In vmnet's
> case about 95% of all packets delivered to the hook is thrown away after
> checking target MAC address (they are not broadcasts & they are not for
> the virtual machine), and in these cases computing checksum is just waste 
> of time.
> 
> So I think that this option should be named PTYPE_FLAG_CANCHECKSUM, and it
> should affect only h.raw assignment - no checksumming should happen.
> 
> For AF_PACKET needs we can create PTYPE_FLAG_NEEDCHECKSUM which would call
> skb_checksum() itself. But I think that adding skb_checksum call to af_packet
> hook itself is simpler.
> 
> We can leave default case (no flags) as is, so hooks which expects h.raw==nh.raw
> still work, and system is not slowed down by doing checksums for hooks which
> do not need it.
> 
> I see only one possible benefit from PTYPE_FLAG_NEEDCHECKSUM: we can checksum
> original skb, potentially saving some cycles in drivers which use 
> skb_csum_and_copy_dev (or when two or more such hooks are registered).

I think this sort of stuff will greatly benefit from the tc extensions
that i have been working on. 
instead of hacking on ptype you can instead write little modules that
do speacilized work (like computing checksums) or dropping packets
or setting these flags that can be later used for doing extra work.
The code executes before the ptype level execution and using the u32
classifier you can grop any part of the packet. I can send you a patch
if you want to give it a shot.

cheers,
jamal
