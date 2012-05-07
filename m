From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 7 May 2012 11:03:28 +0200
Message-ID: <20120507090328.GA27650@1984>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
 <201205021949.48741.hans.schillstrom@ericsson.com>
 <20120506225738.GA23009@1984>
 <201205071020.44449.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201205071020.44449.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2012 at 10:20:42AM +0200, Hans Schillstrom wrote:
> On Monday 07 May 2012 00:57:38 Pablo Neira Ayuso wrote:
> > Hi Hans,
> > 
> > [...]
> > > > > > Regarding ICMP traffic, I think we can use the ID field for the
> > > > > > hashing as well. Thus, we handle ICMP like other protocols.
> > > > >
> > > > > Yes why not, I can give it a try.
> > > > >
> > >
> > > I think we wait with this one..
> > 
> > I see. This is easy to add for the conntrack side, but it will require
> > some extra code for the packet-based solution.
> 
> Actually I think there is very little gain to spread with type 
> and then we must add a user mode possibility to turn it off 
> i.e. a --hmark-icmp-type-mask 
> 
> > Not directly related to this but, I know that your intention is to
> > make this as flexible as possible. However, I still don't find how I
> > would use the port mask feature in any of my setups.  Basically, I
> > don't come up with any useful example for this situation.
> 
> We have plenty of rules where just source port mask is zero.
> and the dest-port-mask is 0xfffc (or 0xffff)

0xffff and 0x0000 means on/off respectively.

Still curious, how can 0xfffc be useful?

> > I'm also telling this because I think that ICMP support will be
> > easier to add if port masking is removed.
> > 
> > [...]
> > > This is what I have done.
> > >
> > > - I reduced the code size a little bit by combining the hmark_ct_set_htuple_ipvX into one func.
> > >   by adding a hmark_addr6_mask() and hmark_addr_any_mask()
> > >   Note that using "otuple->src.l3num" as param 1 in both src and dst is not a typo.
> > >   (it's not set in the rtuple)
> > 
> > Good one, this made the code even smaller.
> > 
> > > - Made the if (dst < src) swap() in the hmark_hash() since it should be used by every caller.
> > 
> > Not really, you don't need for the conntrack part. The original tuple
> > is always the same, not matter where the packet is coming from. I have
> > removed this again so it only affects packet-based hashing.
> 
> Yes original tuple is always the same but not always less than the rtuple.
> If you have two nodes that should produce the same hmark,
> one with conntrack an one without you must make a compare to make it consistent.

I see, for consistency still makes sense although this seems to me
like still strange configuration. In what scenario would you use two
different approaches?

> > > - Moved the L3 check a little bit earlier.
> > 
> > good.
> > 
> > > - changed return values for fragments.
> > 
> > With this, you're giving up on trying to classify fragments. Do you
> > really want this?
> > 
> > From my point of view, if your firewalls (assuming they are the HMARK
> > classification) are stateless, it still makes sense to me to classify
> > fragments using the XT_HMARK_METHOD_L3_4.
> 
> I do agree, it is back to "return 0" again.

OK.
