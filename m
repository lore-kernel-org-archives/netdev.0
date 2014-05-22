From: Jim Baxter <jim_baxter@mentor.com>
Subject: skbuff truesize incorrect.
Date: Thu, 22 May 2014 20:07:41 +0100
Message-ID: <537E4AFD.20304@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <kamal@canonical.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	<edumazet@google.com>, <mszeredi@suse.cz>, <fw@strlen.de>
To: <linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, I was hoping you can help me with some questions.

I have been investigating a network issue with bursts of network traffic
over USB CDC-NCM, the issue is that the kernel is dropping packets
because sk_rcvqueues_full() returns true due to skb2->truesize is always
32960 instead of SKB_TRUESIZE(skb2->len) which is about 1800.

The code I am trying to fix is this code below, it is splitting a set of
multiple network packets compressed into a single 16k packet into
individual skb's and sending them up the network stack.

    skb2 = skb_clone(skb, GFP_ATOMIC);
    if (skb2 == NULL)
        goto err;

    if (!skb_pull(skb2, index)) {
        ret = -EOVERFLOW;
        goto err;
    }

    skb_trim(skb2, dg_len - crc_len);

My questions are:

1) Which buffer size does truesize represent, is it the total buffer or
just the data related to the relevant skb?

2) If truesize is for the skb it is contained within should it be
updated during the call to skb_trim?

3) Why does the truesize default to 32960?


Thank you for any help,
Jim Baxter.
