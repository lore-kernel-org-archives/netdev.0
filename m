From: Christoph Lameter <christoph@graphe.net>
Subject: Compile Error with r8179.c
Date: Sat, 24 Jan 2004 12:25:54 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401241222570.19565@duron.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Could you provide a diff against the current kernel? I applied all the
patches and get the following when compiling:

  CC [M]  drivers/net/8139too.o
  CC [M]  drivers/net/tun.o
  CC [M]  drivers/net/r8169.o
drivers/net/r8169.c:383: error: conflicting types for `timer_t'
include/linux/types.h:32: error: previous declaration of `timer_t'
drivers/net/r8169.c: In function `rtl8169_init_one':
drivers/net/r8169.c:739: error: structure has no member named
`driver_data'
drivers/net/r8169.c: In function `rtl8169_remove_one':
drivers/net/r8169.c:866: error: structure has no member named
`driver_data'
drivers/net/r8169.c:880: error: structure has no member named
`driver_data'
drivers/net/r8169.c: In function `rtl8169_open':
drivers/net/r8169.c:903: warning: passing arg 2 of `request_irq' from
incompatib
le pointer type
drivers/net/r8169.c: In function `rtl8169_set_rx_mode':
drivers/net/r8169.c:1593: warning: passing arg 2 of `set_bit' from
incompatible
pointer type
make[2]: *** [drivers/net/r8169.o] Error 1
make[1]: *** [drivers/net] Error 2

My main problem with the existing driver is that the driver will hang when
I insmod it on my duron system with a VIA mainboard (KLE133). Only the
insmod hangs. I can still login to other sessions and the system operates
normally apart from the hanging process in D state.
