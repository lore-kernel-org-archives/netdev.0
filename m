From: "Lee, Kuk-hyun" <errai110@kornet.net>
Subject: [question] netif_rx() - why don't call raise_softirq()?
Date: Thu, 5 Feb 2004 04:11:58 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <004101c3eb52$c3412d20$5d03c5d3@errai>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I am newbie in the latest kernel development. Nowadays I am starting to work in
linux kernel. BTW, I find kernel code that I can't understand.
in bellow.

netif_rx() in 2.4.19
1238                         dev_hold(skb->dev);
1239                         __skb_queue_tail(&queue->input_pkt_queue,skb);
1240                         /* Runs from irqs or BH's, no need to wake BH */
1241                         cpu_raise_softirq(this_cpu, NET_RX_SOFTIRQ);
1242                         local_irq_restore(flags);

netif_rx() in 2.4.20
1254                         dev_hold(skb->dev);
1255                         __skb_queue_tail(&queue->input_pkt_queue,skb);
1256                         local_irq_restore(flags);

why 2.4.20's netif_rx() don't call raise_softirq()?  Is there never call net_rx_action()? 
maybe, IMHO, because NAPI. but I want to know exactly. I don't know reason why should 
you that. I could not find reason in google or netdev mailling list.

sorry for my stupid question. Any help is highly appriciated.
Thanks,
Lee
