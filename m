From: Florian Westphal <fw@strlen.de>
Subject: Re: BUG: unable to handle kernel paging request at
 0000000000609920 in networking code on 3.2.23.
Date: Fri, 25 Jan 2013 09:28:39 +0100
Message-ID: <20130125082839.GJ8541@breakpoint.cc>
References: <A60E26F6-16DC-4A29-BFDE-1B17DC51F64F@telemetry.com>
 <loom.20130124T115328-292@post.gmane.org>
 <20130124230850.GI8541@breakpoint.cc>
 <alpine.LNX.2.01.1301250124310.21495@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Rafal Kupka <rkupka@telemetry.com>, netdev@vger.kernel.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1301250124310.21495@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt <jengelh@inai.de> wrote:
> On Friday 2013-01-25 00:08, Florian Westphal wrote:
> >@@ -35,10 +35,18 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
> > {
> > 	unsigned int optl, i, j;
> > 	struct tcphdr *tcph;
> >+	struct tcphdr _tcph;
> > 	u_int16_t n, o;
> > 	u_int8_t *opt;
> > 
> >-	if (!skb_make_writable(skb, skb->len))
> >+	if (skb->len < minlen)
> >+		return XT_CONTINUE;
> >+
> >+	tcph = skb_header_pointer(skb, tcphoff, sizeof(_tcph), &_tcph);
> >+	if (!tcph)
> >+		return XT_CONTINUE; /* no options -> nothing to do */
> 
> To the best of my analysis, the "no options" comment is incorrect here,
> because you are not even looking at the options so far, but only tcph.

Yup.

> The prose should probably be something like:
 
> 	if (iph->frag_off & htons(IP_OFFSET)) != 0)
> 		/* not the first fragment - lost case */
> 		return XT_CONTINUE;
[..]

Can to submit a patch?
