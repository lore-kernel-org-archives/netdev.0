From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATH] IPv6 IPsec support
Date: Wed, 05 Mar 2003 20:43:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305.204348.130225511.davem@redhat.com>
References: <20030305233025.784feb00.kazunori@miyazawa.org>
	<20030305.152530.70806720.davem@redhat.com>
	<20030306093219.1a702868.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030306093219.1a702868.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori Miyazawa <kazunori@miyazawa.org>
   Date: Thu, 6 Mar 2003 09:32:19 +0900

   - Extension Header Processing on inbound:
     As a result of IPv6 IPsec support, Extension Header processing is devided
     into ipv6_parse_exthdrs and ipproto->handler. I think it is better to merge
     other Extension Header handling into ipproto->handler.
   
Ok.

   - Fragmentation support on outbound:
     We should change ipv6_build_xmit like ip_append_data style to support
     fragmentation with IPsec.
   
Please work together with Alexey on this.  There are known
major problems on ipv4 side, and it must be resolved before
ipv6 side may be done.

For example, right now a non-TCP packet can do the following.  If it
is just slightly smaller than MTU, and when encapsulated in ESP/AH it
becomes larger than MTU, we will not fragment it and too-large frame
will be sent to device.

In my last round of talks with Alexey I believe we were very close to
a possible solution to this problem.  The idea was to have a "local
dont-fragment" flag, and at the very last stage of IP output we check
this and either 1) clear DF and fragment or 2) drop packet and send
ICMP message back.

Alexey, what is the current state?

   - Removing duplicate codes, clean up and improveing performance.
   
   - Considering relation of IPv6 IPsec and Mobile IPv6. This is future stuff.
   
Ok.
