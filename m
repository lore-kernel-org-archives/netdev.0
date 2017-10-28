From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Linux 4.14-rc6 bisected regression tun devices not working
 anymore in openvpn
Date: Sat, 28 Oct 2017 10:37:27 -0700
Message-ID: <CAM_iQpWfgp3R+Qx59hTcVYuSsPnNWvoDC9=ofkghVM4gguPLzw@mail.gmail.com>
References: <ac1aaeab-b9f5-a034-56a8-4305494db468@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ac1aaeab-b9f5-a034-56a8-4305494db468@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 28, 2017 at 7:57 AM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
> L.S.,
>
> While testing a linux 4.14-rc6 kernel i noticed OpenVPN didn't function anymore.
> My openvpn config uses tun devices and is pretty standard.
> The openvpn version is current Debian stable: openvpn 2.4.0-6+deb9u2
>
> From the openvpn logging:
>     Sat Oct 28 16:03:34 2017 us=175829 TUN/TAP device  opened
>     Sat Oct 28 16:03:34 2017 us=183027 Note: Cannot set tx queue length on : No such device (errno=19)
>     Sat Oct 28 16:03:34 2017 us=183055 do_ifconfig, tt->did_ifconfig_ipv6_setup=0
>     Sat Oct 28 16:03:34 2017 us=183071 /sbin/ip link set dev  up mtu 1500
>     Cannot find device ""
>     Sat Oct 28 16:03:34 2017 us=200445 Linux ip link set failed: external program exited with error status: 1
>     Sat Oct 28 16:03:34 2017 us=200482 Exiting due to fatal error
>     Sat Oct 28 16:38:17 2017 us=923381 TCP/UDP: Closing socket
>     Sat Oct 28 16:38:17 2017 us=925986 Closing TUN/TAP interface
>
>
> The offending commit is:
>     0ad646c81b2182f7fa67ec0c8c825e0ee165696d
>     "tun: call dev_get_valid_name() before register_netdevice()"
>
> Reverting this commit fixes the issue for me, it's unfortunate that the commit it self seems to fix an other issue.

It should be fixed by:

commit 5c25f65fd1e42685f7ccd80e0621829c105785d9
Author: Julien Gomes <julien@arista.com>
Date:   Wed Oct 25 11:50:50 2017 -0700

    tun: allow positive return values on dev_get_valid_name() call

    If the name argument of dev_get_valid_name() contains "%d", it will try
    to assign it a unit number in __dev__alloc_name() and return either the
    unit number (>= 0) or an error code (< 0).
    Considering positive values as error values prevent tun device creations
    relying this mechanism, therefor we should only consider negative values
    as errors here.

    Signed-off-by: Julien Gomes <julien@arista.com>
    Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


Sorry for the trouble.

Thanks.
