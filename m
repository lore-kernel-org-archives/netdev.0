From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 0/5] r8169: intro
Date: Tue, 22 Feb 2005 00:51:25 +0100
Message-ID: <20050221235125.GD26248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1 - The upcoming messages contain a serie of patches which fixes minor issues
    or moderately clean the code.

2 - The current 2.6.11-rc4 r8169 driver would benefit from several patches
    availables in your -netdev serie:
    - the extra netif_poll_enable() in rtl8169_close()
      -> without it the driver can not stand an open/traffic/close/open
         sequence ("interrupt 0005 taken in poll" and the story is over);

    - the endianness changes for vlan
      -> without it a big-endian host can't reach a little endian host
         I tested it through:
         - (old code; little endian) <-> (new code; little endian)
           -> ok 
         - (new code; big endian)    <-> (new code; little endian)
           -> ok 

    - the endianness changes for Rx csum
      -> this one hits big-endian hosts as well but the fix is more trivial
         and it does not bite too hard.

    Imho it would be safe to push the whole queue for inclusion in 2.6.11
    but the changes above are enough if you simply want the smallest set
    of changes to improve the behavior of the driver.

The driver is however not perfect as I can still trigger the pesky
"interrupt xyz taken in poll" error when asking for a change of mtu at
the wrong time.

--
Ueimor
