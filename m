From: "Thomas P." <tom@huno.net>
Subject: CONFIG_NET_CLS_ACT massive debug output
Date: Sun, 29 Aug 2004 00:49:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <145338506.20040829004938@huno.net>
Reply-To: thomas <tom@huno.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,

i'm getting a lot of the following messages:

Aug 28 23:31:32 knecht kernel: ing_filter:  fixed  ppp0 out ppp0
Aug 28 23:32:02 knecht last message repeated 4 times
Aug 28 23:32:32 knecht last message repeated 78 times

Now i found the following:

+ if (NULL == skb->input_dev) {
+    skb->input_dev = skb->dev;
+    printk("ing_filter:  fixed  %s out %s\n",skb->input_dev->name,skb->dev->name);
+ }

and i guess i could just comment it out, but the message is probably there
for a reason. So is there anything wrong? The rule that causes this is:

tc qdisc add dev ppp0 handle ffff: ingress
tc filter add dev ppp0 parent ffff: protocol ip prio 50 u32 match ip src \
   0.0.0.0/0 police rate 1416kbit burst 10k drop flowid :1

Thanks for your help!
Thomas
