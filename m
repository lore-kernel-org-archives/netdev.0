From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: in-driver QoS
Date: Sun, 6 Jun 2004 21:28:47 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406062128.47070.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'd like to discuss issue with QoS.

In 802.11 network, there is TGe (or 802.11e), working group, developing QoS 
extensions for 802.11. This group's work is close to finish. Current draft 
should be very close to the final standard.

Currently, according to TGe, NIC will support 4 different priorities (or 
access categories). Let's say, 4 distinct Tx queues will be supported by NIC. 
Each Tx queue have its own parameters.

In addition, there are separate streams (TSPEC's) that should be requested, 
i.e. before use, some initiation procedure should be performed. Sure, there 
is tear down for TSPEC as well.

Roughly, 4 access categories corresponds to diffserv, while TSPEC's - to 
intserv.

Now, question is: how will we support these QoS features in network stack?

Let's start from diffserv, it is easier.

skb->priority help determining Tx queue, but fundamental problem is with 
single Tx queue from network stack. Any smart queuing/scheduling etc. made by 
driver, will render useless while network stack provides single Tx queue.

Any ideas how to modify stack to support multiple Tx queues?

Vladimir
