From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Tue, 24 Jan 2012 18:56:10 +0100
Message-ID: <201201241856.11732.hans.schillstrom@ericsson.com>
References: <1326448338-13416-1-git-send-email-hans.schillstrom@ericsson.com> <201201231049.17165.hans.schillstrom@ericsson.com> <20120123170150.GA26351@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120123170150.GA26351@1984>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 23 January 2012 18:01:50 Pablo Neira Ayuso wrote:
> Hi Hans,
> 
> On Mon, Jan 23, 2012 at 10:49:16AM +0100, Hans Schillstrom wrote:
> > On Monday 23 January 2012 10:12:41 Pablo Neira Ayuso wrote:
> > > On Mon, Jan 23, 2012 at 12:20:15AM +0100, Hans Schillstrom wrote:
> > > > The text should clarify that this is valid for the fragments not the "flow"
> > > > 
> > > > > I've got one scenario that may break with this assumption:
> > > > > 
> > > > > 1) your traffic follows one path over router A and B to reach your
> > > > >    firewall F which requires no fragmentation at all.
> > 
> > I missed the last part here  "requires no fragmentation at all"
> > 
> > > > > 2) path to router B becomes broken while there are established flows
> > > > >    with firewall F.
> > > > > 3) router A decides to forward packets to router C, which fragment
> > > > >    packets because it is using smaller MTU than router A.
> > > > > 4) packets arrive to firewall F, then hashing is calculated based on
> > > > >    addresses, not ports, and you load-sharing becomes inconsistent.
> > > > > 
> > > > > This can rarely happen, but it does, it would break.
> > > > > 
> > > > > To fix this, I think that HMARK requires that you have to specify the
> > > > > hashing strategy. If you want to support fragments, use only
> > > > > addresses. If you're sure you will not get fragments, use layer 3 and
> > > > > layer 4 information.
> > 
> > This can be acomplished by setting --hmark-sp-mask and --hmark-dp-mask to Zero
> > Then you don't use port in the hash calc.
> 
> OK, it would be great if we can provide a cleaner interface. The
> current behaviour uses layer3-layer4 tuple hashing plus defaulting to
> layer3 in case of fragments.
> 
> I'd prefer explicit configuration options:
> 
> --hashmark-method layer3
>         use only address for hashing, this is fragment safe.
> 
> --hashmark-method layer3-layer4
>         use addresses and ports for hashing, fragments not supported
>         unless defrag is enabled.
> 
> Still, if you want to support the current behaviour, it should be
> something like:
> 
> --hashmark-method layer3-layer4-fragments
>         use addresses and ports for hashing, for fragments default to
>         layer3 hashing. Document scenario in which hash consistency
>         may break.
> 
> The behaviour of the target has to be specified by the configurations.
> Defaulting to internal assumptions seems obscure to me.
> 
OK this is resonable, and it makes the fragment problem visible.

I'll make the changes to day and have a test run for a couple of days.
or should I wait ?

Tanks
Hans 
