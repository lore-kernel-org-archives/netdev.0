From: Michael Renzmann <mrenzmann@web.de>
Subject: Deleting incoming network packets / sk_buff
Date: Sat, 14 Aug 2004 21:12:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411E642C.9010708@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all.

I'm just making my first steps in kernel programming, and I have a few 
questions.

It's necessary for me to "delete" network packets that come in on a 
ethernet device after passing them to an userspace program (through a 
packet socket that the program has opened). My first idea was to write a 
kernel module that registers on the NF_IP_PRE_ROUTING netfilter hook and 
does its job. But there are two downsides on this approach:

1. I need to delete every packet, no matter if it is IP or something 
else. As far as I understood only IP-packets will pass the netfilter 
hooks, since the netfilter framework only works with IP traffic.

2. The solution also has to work for 2.2.x kernels, as long as there is 
any way to achieve this functionality for these kernel series and 2.4.x 
as well.

I continued to dig some documentation, and found a possible solution in 
a rather old phrack article [1]: "What we do is code our own kernel 
module that registers our packet_type{} data structure to handle all 
incoming packets (sk_buff's) right after they come out of the device 
driver." While the authors use this technique to implement some 
"protocol obfuscation" or an in-kernel packet sniffer, it seems to be a 
good way to reach what I want to do.

Now, what I'm wondering about is the way to "correctly" remove an 
sk_buff so that the upper layer won't see the corresponding packet. I 
somewhere read that the code for packet sockets have to clone the 
sk_buff before passing it to the socket, else it would be "lost" and 
could not be seen by following handlers.

So, the questions I have:

1. What has to be done to delete a bypassing sk_buff, so that upper 
layer routines don't see it?

2. How can it be achieved to pass a sk_buff to opened packet sockets 
before deleting the sk_buff? I guess the handler either has to pass the 
sk_buff "manually" to the packet socket handler packet_rcv() or has to 
place itself to be called directly after packet_rcv() has been called.

I hope that my description can be understood - not enough that I'm not 
very keen with kernel programming, but I also am no native english 
speaker... :) Please let me know if you need further information to clarify.

Bye, Mike

[1] http://www.phrack.org/show.php?p=55&a=12
