From: Tobias Lorenz <tobias.lorenz@gmx.net>
Subject: linux starfire.c network driver problem under kernel 2.6.x
Date: Fri, 06 Aug 2004 16:56:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091804213.2981.2.camel@server.lorenz.priv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,


first a compile fix, which is needed to compile with HAS_FIRMWARE:
<<< snip
@@ -1409,7 +1409,7 @@
                }

                if (has_bad_length)
-                       skb_checksum_help(skb);
+                       skb_checksum_help(skb, 0);
        }
 #endif /* ZEROCOPY && HAS_BROKEN_FIRMWARE */
<<< snap
Explanation: There was a change in the "skb_checksum_help" function. It
now has the additional argument "inward", which must be 0 when called in
function "start_tx". The patch above, makes the driver compile again.


More problematic is that there are no network connections possible with
the card running under a 2.6 kernel. That card runs okay under linux
2.4.26. I tried with kernel 2.6.7 and 2.6.8-rc2. I also tried with
acpi=off, noapic, pci=noacpi, pci=biosirq. Nothing worked.

And yes: Routing is configured correctly, Firewall is down. Ifconfig
shows running interfaces, /proc/interrupts shows the interfaces.

I tried to compile the module with the following options
enabled/disabled:
- HAS_FIRMWARE
- VLAN_SUPPORT (CONFIG_VLAN_8021Q, CONFIG_VLAN_8021Q_MODULE)
- HAVE_NETDEV_POLL (CONFIG_ADAPTEC_STARFIRE_NAPI)

A friend of mine with a complete different system and kernel config
(board, SMP) tried a while ago with kernels 2.6.0 and 2.6.5
independently of me and had the same problem too.

I saw no significant changes between the versions from 2.4.26 to 2.6.7.
So I don't think the problem comes directly from the driver.

The following could let to a clew:
lsmod shows that the starfire module depends on mii, but the starfire
module itself shows no module usage!

Last time I tried, I got the following errors:
Something wicked happened! 0x02018101.
Something wicked happened! 0x02010001.

What else information can I give you ? The LEDs on my switch blink when
running a ping. So at least one direction does something. I have not
checked, if that's sending or receiving and if packets are corrupted.
Could be difficult to test. That system is my NFS server for all my
diskless clients...

I found a similar thread, that's maybe related:
http://lkml.org/lkml/2004/1/5/225

Thanks,
  Toby
