From: Toby DiPasquale <toby@cbcg.net>
Subject: Re: off-by-one in DecodeQ931
Date: Tue, 3 May 2016 01:12:06 -0400
Message-ID: <CAML0wpGWvcpB5GE_zAjOeO6ki_nszaj+hR9yyadwu_3hQno7Cg@mail.gmail.com>
References: <CAML0wpEBwXdzWX7g3LDJRDOVM0J7dkuhH8b+96ZhRf54+qUgwQ@mail.gmail.com>
	<20160425152905.GA8621@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pablo@netfilter.org, Patrick McHardy <kaber@trash.net>,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160425152905.GA8621@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 25, 2016 at 11:29 AM, Florian Westphal <fw@strlen.de> wrote:
> -> sz (size_t) will underflow here
>
> I'd suggest to change the if (sz < 1) to if (sz < 2) to
> resolve this, the while loop below has to be taken anyway.

Thanks, Florian! Updated patch below:

Signed-off-by: Toby DiPasquale <toby@cbcg.net>

diff --git a/net/netfilter/nf_conntrack_h323_asn1.c
b/net/netfilter/nf_conntrack_h323_asn1.c
index bcd5ed6..89b2e46 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -846,9 +846,10 @@ int DecodeQ931(unsigned char *buf, size_t sz, Q931 *q931)
        sz -= len;

        /* Message Type */
-       if (sz < 1)
+       if (sz < 2)
                return H323_ERROR_BOUND;
        q931->MessageType = *p++;
+       sz--;
        PRINT("MessageType = %02X\n", q931->MessageType);
        if (*p & 0x80) {
                p++;
