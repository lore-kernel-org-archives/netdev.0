From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: sparc oops in ip_fast_csum
Date: Sun, 6 Jan 2008 01:57:13 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801060156410.14194@fbirervta.pbzchgretzou.qr>
References: <E1JBJHA-0000hy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Al Viro <viro@ZenIV.linux.org.uk>, m.kozlowski@tuxland.pl,
	davem@davemloft.net, sparclinux@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757651AbYAFA51@vger.kernel.org>
In-Reply-To: <E1JBJHA-0000hy-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jan 6 2008 11:22, Herbert Xu wrote:
>@@ -271,6 +271,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
> 	int hh_len;
> 	struct iphdr *iph;
> 	struct sk_buff *skb;
>+	unsigned int iphlen;
> 	int err;
> 
> 	if (length > rt->u.dst.dev->mtu) {
>@@ -304,7 +305,8 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
> 		goto error_fault;
> 
> 	/* We don't modify invalid header */
>-	if (length >= sizeof(*iph) && iph->ihl * 4U <= length) {
>+	iphlen = iph->ihl * 4;
>+	if (iphlen >= sizeof(*iph) && iphlen <= length) {

Humm, this could use ip_hdrlen(skb) :-)
