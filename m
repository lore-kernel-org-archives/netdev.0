From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/6] PKT_SCHED: u32 ematch
Date: Mon, 24 Jan 2005 01:58:53 +0100
Message-ID: <20050124005853.GN23931@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch> <20050123230354.GF23931@postel.suug.ch> <41F4402D.6040200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41F4402D.6040200@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41F4402D.6040200@trash.net> 2005-01-24 01:24
> Thomas Graf wrote:
> >+static int em_u32_match(struct sk_buff *skb, struct tcf_ematch *em,
> >+			struct tcf_pkt_info *info)
> >+{
> >+	struct tc_u32_key *key = (struct tc_u32_key *) em->data;
> >+	unsigned char *ptr = skb->nh.raw;
> >+	
> >+	if (info) {
> >+		if (info->ptr)
> >+			ptr = info->ptr;
> >+		ptr += (info->nexthdr & key->offmask);
> >+	}
> >+	
> >+	return !((*(u32*) (ptr + key->off) ^ key->val) & key->mask);
> > 
> >
> This needs to make sure it stays inside the skb. I know cls_u32's checks
> are pretty weak, but having nothing doesn't seem right.

It's a exact copy with all the weaknesses inherited. I'll add a
call to tcf_valid_offset, we'll lose the _feature_ to match areas
in the page beyond the skb data though. ;->
