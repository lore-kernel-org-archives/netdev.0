From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Linux 4.14-rc6 bisected regression tun devices not working anymore in
 openvpn
Date: Sat, 28 Oct 2017 16:57:48 +0200
Message-ID: <ac1aaeab-b9f5-a034-56a8-4305494db468@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L.S.,

While testing a linux 4.14-rc6 kernel i noticed OpenVPN didn't function anymore. 
My openvpn config uses tun devices and is pretty standard.
The openvpn version is current Debian stable: openvpn 2.4.0-6+deb9u2

>From the openvpn logging:
    Sat Oct 28 16:03:34 2017 us=175829 TUN/TAP device  opened
    Sat Oct 28 16:03:34 2017 us=183027 Note: Cannot set tx queue length on : No such device (errno=19)
    Sat Oct 28 16:03:34 2017 us=183055 do_ifconfig, tt->did_ifconfig_ipv6_setup=0
    Sat Oct 28 16:03:34 2017 us=183071 /sbin/ip link set dev  up mtu 1500
    Cannot find device ""
    Sat Oct 28 16:03:34 2017 us=200445 Linux ip link set failed: external program exited with error status: 1
    Sat Oct 28 16:03:34 2017 us=200482 Exiting due to fatal error
    Sat Oct 28 16:38:17 2017 us=923381 TCP/UDP: Closing socket
    Sat Oct 28 16:38:17 2017 us=925986 Closing TUN/TAP interface


The offending commit is: 
    0ad646c81b2182f7fa67ec0c8c825e0ee165696d
    "tun: call dev_get_valid_name() before register_netdevice()" 

Reverting this commit fixes the issue for me, it's unfortunate that the commit it self seems to fix an other issue.

--
Sander
