From: Kristian Evensen <kristrev@ifi.uio.no>
Subject: Non-linear SKBs
Date: Fri, 12 Oct 2007 00:54:37 +0200
Message-ID: <470EA9AD.4020304@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: linux-net@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have developed a small patch for the TCP code in 2.6.19 and it works 
flawlessly. A couple of days ago I decided to make it compatible with 
2.6.22.5 and have stumbled upon a problem I cannot solve.

In 2.6.19 it seems that all packets (at least the ones my patch work 
with) are linear, while they are non-linear in 2.6.22.5. I have searched 
through the code (focusing on tcp_sendmsg) to try to figure out what 
happens, but can't find any differences that would explain this. Does 
anyone know what might be the cause and if there is an easy way to 
return to linear skbs (unless that is totally stupid)? I would also like 
the benefits offered by the collapsing when retransmitting (which 
requires number of fragments to be 0).

Currently I us e the skb_linearize(skb) on all fragmentet packets, which 
is not nice :) Both kernels are vanilla kernels with the patch applied, 
and I used OpenSuse with 2.6.19 and Ubuntu with 2.6.22.5 (but I guess 
that shouldn't matter in this case).

The reason this is a problem is that I copy data between SKBs, and in 
2.6.19 I have used memcpy for this purpose. I have looked at the way the 
kernel copies data into a non-linear skb in the else-part of the large 
if-test in tcp_sendmsg and the skb_copy_bits-function, but I have to 
admit that I think the first one is a bit advanced and I don't quite 
understand how to use the last one. Does anyone have any easier to 
understand examples or explanations on how to copy data from one 
non-linear skb to another?

Thanks.

-Kristian
