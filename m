From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: commit f5f99309 (sock: do not set sk_err in sock_dequeue_err_skb)
 has broken ping
Date: Thu, 1 Jun 2017 11:15:12 -0400
Message-ID: <CACSApvanT0ZRFH0ZBDLqygkH6Ue_CCVQBzVL9fCmZE_BndYEog@mail.gmail.com>
References: <20170601140048.GA24401@rei.lan> <CACSApvZiQTYSVkS62YdadjabUTqwO9O2=Sq4ELuO3eoJ_LM_ZQ@mail.gmail.com>
 <20170601143141.GB24401@rei.lan> <CACSApvbKwbX2u16V1oQfmHC7SvGZgk-KehA9tashjQAtj0bB0Q@mail.gmail.com>
 <20170601151003.GB10526@rei.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Yaogong Wang <wygivan@google.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Cyril Hrubis <chrubis@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601151003.GB10526@rei.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 1, 2017 at 11:10 AM, Cyril Hrubis <chrubis@suse.cz> wrote:
>> Thank you for the confirmation. Could you please try the following
>> patch to see if it fixes your issue?
>
> Does not seem to help, I still got the same bussy loop.

Thank you for trying the patch. Unfortunately, I can't reproduce on my
machines here.Would you humor me with another one? Thank you!

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a726161f4e4..49207298fcea 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3742,7 +3742,8 @@ EXPORT_SYMBOL(sock_queue_err_skb);
 static bool is_icmp_err_skb(const struct sk_buff *skb)
 {
        return skb && (SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
-                      SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP6);
+                      SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP6 ||
+                      SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_LOCAL);
 }

 struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
