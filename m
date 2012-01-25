From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Wed, 25 Jan 2012 13:28:23 +0100
Message-ID: <201201251328.24996.hans.schillstrom@ericsson.com>
References: <1326448338-13416-1-git-send-email-hans.schillstrom@ericsson.com> <201201251114.34774.hans.schillstrom@ericsson.com> <20120125114932.GB6842@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120125114932.GB6842@1984>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 25 January 2012 12:49:32 Pablo Neira Ayuso wrote:
> On Wed, Jan 25, 2012 at 11:14:33AM +0100, Hans Schillstrom wrote:
> > Here is help text and man page just to clarify the changes:
> > Is this clear enough ?
> > 
> > HMARK target options, i.e. modify hash calculation by:
> >   --hmark-method <method>            Overall L3/L4 and fragment behavior
> >                  L3                  Fragment safe, do not use ports or protocol
> >                                      i.e  Fragments don't need special care.
> > 
> >                  L3-4 (Default)      Fragment unsafe, use ports and protocol
> >                                      if defrag is off in conntrack
> >                                         no hmark produced on any part of fragments.
> 
> This is fine.
> 
> >   Limit/modify the calculated hash mark by:
> >   --hmark-mod value                  nfmark modulus value
> >   --hmark-offs value                 Last action add value to nfmark
>             ^^^^
> no need to be cryptic here, just say offset.

OK
> 
> >  Fine tuning of what will be included in hash calculation
> >   --hmark-smask length               Source address mask length
>             ^^^^^

OK

> 
> I'd say hmark-src-mask to keep it consistent with the options in
> iptables.
> 
> >   --hmark-dmask length               Dest address mask length
> 
> hmark-dst-mask
OK
> 
> >   --hmark-sp-mask value              Mask src port with value
> 
> hmark-sport-mask
OK
> 
> >   --hmark-dp-mask value              Mask dst port with value
> 
> hmark-dport-mask
OK
> 
> >   --hmark-spi-mask value             For esp and ah AND spi with value
> 
> hmark-ah-spi-mask
No, it is for esp as well so I think spi is enough

> 
> >   --hmark-sp-set value               OR src port with value
> 
> hmark-sport-or
> 
> >   --hmark-dp-set value               OR dst port with value
> 
> hmark-dport-or
> 
> >   --hmark-spi-set value              For esp and ah OR spi with value
> 
> These three can be useful? Providing lots of options is fine, but they
> may confuse users. What do we gain from this?
> 
> In other words, is it possible to deploy consistent hashing with some
> sane configuration using these options?

Ex if you want stickiness between ports ex 80 and 443
iptables  -p tcp --dport 443 -j HMARK --sport-mask 0 --dport-set 80 ....
iptables  ...  -j HMARK --sport-mask 0 ....

Usefull or not that can be discussed.
>From my point of view it's not a "MUST"

> 
> >   --hmark-proto-mask value           Mask Protocol with value
>                                        ^^^^^^^^^^^ ^^^ ^^^ ^^^^
> useful?
Yes, stickiness between protocols (in most cases --sport-mask needs to be zero)
ex sip uses both TCP and UDP port 5060

> 
> >   --hmark-rnd                        Initial Random value to hash cacl.
> >  For NAT in IPv4 the original address can be used in the return path.
> 
> We'll have IPv6 NAT soon. Please, make sure we can extend HMARK to
> support IPv6 support.

Sure, allready tesed.

> 
> >  Make sure to qualify the statement in a proper way when using nat flags
> 
> this description is fine. I'd propose to change the option names
> below:
> 
> >   --hmark-dnat                       Replace src addr with original dst addr
> >   --hmark-snat                       Replace dst addr with original src addr
> 
> better:
> 
> --hmark-ct-orig-src
> --hmark-ct-orig-dst

I agree, thanks

> 
> >  In many cases hmark can be omitted i.e. --smask can be used
> 
> Thanks again.
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
