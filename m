From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] PKT_SCHED: Simple comparison ematch (cmp)
Date: Mon, 24 Jan 2005 01:55:43 +0100
Message-ID: <20050124005543.GM23931@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch> <20050123230221.GD23931@postel.suug.ch> <41F43DD4.8070306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41F43DD4.8070306@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41F43DD4.8070306@trash.net> 2005-01-24 01:14
> Thomas Graf wrote:
> >+static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
> >+			struct tcf_pkt_info *info)
> >+{
> >+	struct tcf_em_cmp *cmp = (struct tcf_em_cmp *) em->data;
> >+	unsigned char *ptr = tcf_get_base_ptr(skb, cmp->layer) + cmp->off;
> >+	u32 val = 0;
> >+
> >+	if (!tcf_valid_offset(skb, ptr, cmp->align))
> >+		return 0;
> >+
> >+	switch (cmp->align) {
> >+		case TCF_EM_ALIGN_U8:
> >+			val = *ptr;
> >+			break;
> >+
> >+		case TCF_EM_ALIGN_U16:
> >+			val = *ptr << 8;
> >+			val |= *(ptr+1);
> >+
> >+			if (cmp_needs_transformation(cmp))
> >+				val = be16_to_cpu(val);
> > 
> >
> Why not simply convert cmp->val in userspace ?

To allow comparing with lt and gt. I favoured transforming over byte
order specific comparison routines.
