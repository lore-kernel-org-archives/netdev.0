From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/2] nf_nat: make unique_tuple return void
Date: Sat, 31 Jul 2010 20:47:31 +0800
Message-ID: <AANLkTimhzYNROE_5AsPJZdjBT+sQmiR5+cT-26BR3m1k@mail.gmail.com>
References: <1280542516-14567-1-git-send-email-xiaosuo@gmail.com>
	<alpine.LSU.2.01.1007311352490.17359@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007311352490.17359@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2010 at 7:54 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
> On Saturday 2010-07-31 04:15, Changli Gao wrote:
>
>>the only user of unique_tuple() get_unique_tuple() doesn't care about the
>>return value of unique_tuple(), so make unique_tuple() return void (nothing).
>
> Shouldn't the callers (get_unique_tuple in nf_nat_core.c) ideally
> return NF_DROP or something such that connections that cannot be
> uniquely mangled be rejected rather than forwarded without mangling?
>

 220/* Manipulate the tuple into the range given.  For NF_INET_POST_ROUTING,
 221 * we change the source to map into the range.  For NF_INET_PRE_ROUTING
 222 * and NF_INET_LOCAL_OUT, we change the destination to map into the
 223 * range.  It might not be possible to get a unique tuple, but we try.
 224 * At worst (or if we race), we will end up with a final duplicate in
 225 * __ip_conntrack_confirm and drop the packet. */
 226static void
 227get_unique_tuple(struct nf_conntrack_tuple *tuple,
 228                 const struct nf_conntrack_tuple *orig_tuple,
 229                 const struct nf_nat_range *range,
 230                 struct nf_conn *ct,
 231                 enum nf_nat_manip_type maniptype)

the above is the comment for get_unique_tuple(). So no connection is
forwarded without mangling.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
