From: Jeff Garzik <jgarzik@pobox.com>
Subject: IPv6 "badness" in recent releases
Date: Sun, 14 Nov 2004 14:04:00 -0500
Message-ID: <4197AC20.6020707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
 <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


So, while ssh'ing _successfully_ to a DNS server I maintain, I noticed 
that my gateway would grind its disk whenever traffic flowed through the 
ssh connection.

I login (same machine that used to have the "BUG: dst underflow" 
problems) and see

[first one I can find in log]
Badness in dst_release at include/net/dst.h:149
  [<f8c0f169>] ip6_dst_check+0x64/0x6a [ipv6]
  [<f8c060ab>] ip6_dst_lookup+0x17b/0x195 [ipv6]
  [<f8c18366>] udpv6_sendmsg+0x2bb/0x934 [ipv6]
  [<c031a41f>] udp_recvmsg+0x60/0x2e9
  [<c032161d>] inet_sendmsg+0x4d/0x59
  [<c02d4588>] sock_sendmsg+0xe8/0x103
  [<c011eafd>] find_busiest_group+0xcf/0x2db
  [<c01eec8c>] copy_from_user+0x42/0x6e
  [<c0136c86>] autoremove_wake_function+0x0/0x57
  [<c02d5ea6>] sys_sendmsg+0x189/0x1e6
  [<c011f7ec>] __wake_up_common+0x3f/0x5e
  [<c011f84b>] __wake_up+0x40/0x56
  [<c01372f5>] wake_futex+0x37/0x62
  [<c0137394>] futex_wake+0x74/0xc4
  [<c01eec8c>] copy_from_user+0x42/0x6e
  [<c02d6330>] sys_socketcall+0x236/0x254
  [<c0105f11>] sysenter_past_esp+0x52/0x71

[current ones]
Badness in dst_release at include/net/dst.h:149
  [<f8c0dde5>] ipip6_tunnel_xmit+0x5e9/0x7c8 [ipv6]
  [<c011dd83>] try_to_wake_up+0x1f3/0x2c9
  [<c02ddaf7>] dev_queue_xmit+0xd1/0x272
  [<f8c04a24>] ip6_output2+0x18c/0x29e [ipv6]
  [<f8c05416>] ip6_forward+0x148/0x3e6 [ipv6]
  [<f8c07222>] ipv6_rcv+0x142/0x284 [ipv6]
  [<c02de147>] netif_receive_skb+0x12f/0x18f
  [<f8be9387>] e1000_clean_rx_irq+0x12e/0x447 [e1000]
  [<c02d82af>] __kfree_skb+0x83/0x107
  [<f8be8fc8>] e1000_clean+0x51/0xca [e1000]
  [<c02de329>] net_rx_action+0x77/0xf6
  [<c01281f3>] __do_softirq+0xb7/0xc6
  [<c012822f>] do_softirq+0x2d/0x2f
  [<c0108362>] do_IRQ+0x1e/0x24
  [<c010694a>] common_interrupt+0x1a/0x20
  [<c010401e>] default_idle+0x0/0x2c
  [<c0104047>] default_idle+0x29/0x2c
  [<c01040b0>] cpu_idle+0x33/0x3c

filling my logs.

This is i686 HyperThreaded (fake SMP) box running 2.6.10-rc1-bk16.

As I mentioned at the beginning of the message, IPv6 still seems to 
function.  It just fills my kernel ring buffer with these BUG messages.

	Jeff
