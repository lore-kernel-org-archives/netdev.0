From: Jeff Garzik <jgarzik@pobox.com>
Subject: Badness in dst_release
Date: Thu, 16 Dec 2004 02:46:29 -0500
Message-ID: <41C13D55.3070002@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
 <yoshfuji@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


After a week or more of uptime, the "Badness in dst_release" messages 
started again.  Kernel 2.6.10-rc3-bk2.  The first message is below.

Arnaldo and Yoshifuji should have already have access to this machine 
(although I just rebooted into -bk-latest)

IMO, if you want additional debugging code, add some non-intrusive 
checks in the upstream kernel.  Since this problem doesn't appear for a 
while, additional checks would be useful.

Badness in dst_release at include/net/dst.h:149
  [<f8c1124d>] ip6_dst_check+0x64/0x6a [ipv6]
  [<f8c080da>] ip6_dst_lookup+0x1a7/0x1c1 [ipv6]
  [<f8c1a4e6>] udpv6_sendmsg+0x297/0x931 [ipv6]
  [<c03194ef>] udp_recvmsg+0x60/0x2e9
  [<c032086d>] inet_sendmsg+0x4d/0x59
  [<c02d33d8>] sock_sendmsg+0xe8/0x103
  [<c011bb37>] find_busiest_group+0xcf/0x2db
  [<c011bfb9>] load_balance_newidle+0x36/0xb4
  [<c01ec15c>] copy_from_user+0x42/0x6e
  [<c0133fd2>] autoremove_wake_function+0x0/0x57
  [<c02d4cf6>] sys_sendmsg+0x189/0x1e6
  [<c0355e24>] schedule_timeout+0xbd/0xbf
  [<c0134a47>] unqueue_me+0x5a/0xa5
  [<c0133dda>] add_wait_queue+0x1a/0x46
  [<c0134be4>] futex_wait+0x152/0x170
  [<c014ecd4>] find_extend_vma+0x29/0x7e
  [<c011c7d5>] default_wake_function+0x0/0x12
  [<c01346e0>] futex_wake+0x74/0xc4
  [<c01ec15c>] copy_from_user+0x42/0x6e
  [<c02d5180>] sys_socketcall+0x236/0x254
  [<c0102f0d>] sysenter_past_esp+0x52/0x71
