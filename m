From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 21:44:30 +0800
Message-ID: <CAM_iQpVdqYceHejqyQOn5wqj-xQFjn6E4u5ws4MuoOd=SiVtww@mail.gmail.com>
References: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
	<20121223114213.GB8386@liondog.tnic>
	<CA+icZUXeddp5UZ10ZWTsWLnmegHGJ+VHnr4=oAm34hXgHD2FDg@mail.gmail.com>
	<CA+icZUU2OdNq5WKd7abNNe2eevxZBbMRS0eBGyU_rzjVBAgcOg@mail.gmail.com>
	<CA+icZUVxdp-Lcf4FLfY-80qvVsTQn-ajfh8vn2T=FC6-QbLv7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Borislav Petkov <bp@alien8.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUVxdp-Lcf4FLfY-80qvVsTQn-ajfh8vn2T=FC6-QbLv7w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 23, 2012 at 9:19 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>
> The culprit commit here seems to be...
>
> commit 9650388b5c56578fdccc79c57a8c82fb92b8e7f1
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Fri Dec 21 07:32:10 2012 +0000
>
>     ipv4: arp: fix a lockdep splat in arp_solicit()

Can you try the following one-line fix?

Thanks.

------------>

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1169ed4..75e0d7c 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -365,7 +365,7 @@ static void arp_solicit(struct neighbour *neigh,
struct sk_buff *skb)
                        pr_debug("trying to ucast probe in NUD_INVALID\n");
                neigh_ha_snapshot(dst_ha, neigh, dev);
        } else {
-               memset(dst_ha, 0, dev->addr_len);
+               memcpy(dst_ha, dev->broadcast, MAX_ADDR_LEN);
                probes -= neigh->parms->app_probes;
                if (probes < 0) {
 #ifdef CONFIG_ARPD
