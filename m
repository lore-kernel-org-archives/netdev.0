From: Jeff Garzik <jgarzik@pobox.com>
Subject: Badness in dst_release at include/net/dst.h:149
Date: Fri, 26 Nov 2004 21:58:32 -0500
Message-ID: <41A7ED58.7030906@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
 <yoshfuji@linux-ipv6.org>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This just appeared on my router (which Yoshfuji and Arnaldo have access to):

Badness in dst_release at include/net/dst.h:149
  [<f8c111c5>] ip6_dst_check+0x64/0x6a [ipv6]
  [<f8c080da>] ip6_dst_lookup+0x1a7/0x1c1 [ipv6]
  [<f8c1a45e>] udpv6_sendmsg+0x297/0x931 [ipv6]
  [<c031bf3f>] udp_recvmsg+0x60/0x2e9
  [<c0323199>] inet_sendmsg+0x4d/0x59
  [<c02d5e28>] sock_sendmsg+0xe8/0x103
  [<c011bb13>] find_busiest_group+0xcf/0x2db
  [<c01ec088>] copy_from_user+0x42/0x6e
  [<c0133dda>] autoremove_wake_function+0x0/0x57
  [<c02d7746>] sys_sendmsg+0x189/0x1e6
  [<c035874c>] schedule_timeout+0xbd/0xbf
  [<c011c802>] __wake_up_common+0x3f/0x5e
  [<c011c861>] __wake_up+0x40/0x56
  [<c0134449>] wake_futex+0x37/0x62
  [<c01344e8>] futex_wake+0x74/0xc4
  [<c0128f57>] update_wall_time+0xa/0x37
  [<c01ec088>] copy_from_user+0x42/0x6e
  [<c02d7bd0>] sys_socketcall+0x236/0x254
  [<c0102f15>] sysenter_past_esp+0x52/0x71

This was the first 'Badness' message I can find, but several now follow 
this one.

uname -a:
Linux gw.yyz.us 2.6.10-rc2-bk6 #1 SMP Sun Nov 21 15:24:40 EST 2004 i686 
i686 i386 GNU/Linux
