From: Florian Westphal <fw@strlen.de>
Subject: Re: bridge: Do not compile options in br_parse_ip_options
Date: Sat, 4 Oct 2014 20:06:47 +0200
Message-ID: <20141004180647.GB1241@breakpoint.cc>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
 <20141004100413.GA1241@breakpoint.cc>
 <20141004135508.GA10705@gondor.apana.org.au>
 <20141004141802.GA10878@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	bsd@redhat.com, stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44018 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034AbaJDSG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 14:06:57 -0400
Content-Disposition: inline
In-Reply-To: <20141004141802.GA10878@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Sat, Oct 04, 2014 at 09:55:08PM +0800, Herbert Xu wrote:
> >
> > I'll try to create a patch that essentially reverts the patch
> > that led us here.
> 
> Here is a patch that's only compile-tested:
> 
> bridge: Do not compile options in br_parse_ip_options
> 
> Commit 462fb2af9788a82a534f8184abfde31574e1cfa0
> 
> 	bridge : Sanitize skb before it enters the IP stack
> 
> broke when IP options are actually used because it mangles the
> skb as if it entered the IP stack which is wrong because the
> bridge is supposed to operate below the IP stack.
> 
> Since nobody has actually requested for parsing of IP options
> this patch fixes it by simply reverting to the previous approach
> of ignoring all IP options, i.e., zeroing the IPCB.

Fair enough.  We lose frag_max_size information from ipv4 defrag,
plus netfilter hooks are called without validating ip options.

The former has not worked ever with bridge, and the latter
evidentily isn't a problem either since this has not worked at all
for three years...

So I am fine with it, provided we rename br_parse_ip_options() --
thats not what it does after this patch (br_validate_iphdr(), for
example?)

> If and when somebody who uses IP options and actually needs them
> to be parsed by the bridge complains then we can revisit this.

Ok, fair enough.

Thanks Herbert.
