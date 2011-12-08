From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: IPv6 defrag question ?
Date: Thu, 8 Dec 2011 14:29:17 +0100
Message-ID: <201112081429.18441.hans.schillstrom@ericsson.com>
References: <jec613b.4edd5c40857133156bf40cef475e9234@obelix.schillstrom.com> <201112081012.13065.hans.schillstrom@ericsson.com> <4EE09B39.5070401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4EE09B39.5070401@trash.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 December 2011 12:10:49 Patrick McHardy wrote:
> On 12/08/2011 10:12 AM, Hans Schillstrom wrote:
> > Hi
> > While testing HMARK and IPv6 with nf_defrag_ipv6 (and nf_conntrack_ipv6 loaded) I can't see the defrag ?
> >
> >  From what I can see nf_conntrack_reasm goes into PREROUTING with prio -400
> > and HMARK in PREROUTING with prio -150
> >
> > I was expecting that the reasaembled packet whould reach HMARK not the fragments.
> >
> > (Debug print from hmark)
> > HMARK() mark:489, hash:4d04eaa1, frag:1, nhoffs:30 plen:1408 (2008::10 - 1000::1)
> > HMARK() mark:489, hash:4d04eaa1, frag:1, nhoffs:0  plen:86 (2008::10 - 1000::1)
> >
> > IPv4 do reassm. the packets not IPv6...
> 
> Yeah, IPv6 currently only passes the defragmented packet through conntrack,
> then associates the conntrack information with the individual fragments and
> passes those on. I'll post patches for IPv6 NAT which will change this
> to behave similar to IPv4 soon.
> 
OK great, current beaiviour was kind of unexpected.

BTW this piece of code looks like it's broken
or I might have missunderstod this :-)
at least  /* queued */ causes some confusion .

static unsigned int ipv6_defrag(unsigned int hooknum,
...
	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
	/* queued */
	if (reasm == NULL)
		return NF_STOLEN;

NF_STOLEN will only be returned when nf_ct_frag6_reasm() returns an error.
 (called by ct_frag6_gather)


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
