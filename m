From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 4180] New: masquarade and source ip
Date: Tue, 8 Feb 2005 07:25:35 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0502080706070.32526@kaber.coreworks.de>
References: <20050207111822.65038881.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, spied@yandex.ru
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050207111822.65038881.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The masquerading code got simplified and uses inet_select_addr() instead
of querying routing for the source address now. This means it will
usually pick the first address on the device, except for gatewayed
routes, in which case it will try to find an address in the network of
the gateway. Users should use SNAT for setups with multiple IPs, in this
case it is also possible to specify a netmask in "ip addr add 2.3.4.5"
so it will be prefered for the gateway 2.3.4.6.

Regards
Patrick

On Mon, 7 Feb 2005, Andrew Morton wrote:

>
>
> Begin forwarded message:
>
> Date: Mon, 7 Feb 2005 10:16:56 -0800
> From: bugme-daemon@osdl.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 4180] New: masquarade and source ip
>
>
> http://bugme.osdl.org/show_bug.cgi?id=4180
>
>           Summary: masquarade and source ip
>    Kernel Version: 2.6.10
>            Status: NEW
>          Severity: normal
>             Owner: laforge@gnumonks.org
>         Submitter: spied@yandex.ru
>
>
> i try next on router (eth0 - inernet, eth1 - localnet):
>
> ip addr add eth0 1.2.3.4
> ip addr add eth0 2.3.4.5
>
> ip route add default via 2.3.4.6 src 2.3.4.5
>
> iptables  -t nat -A POSTROUTING -s 10.0.0.0/8 -d ! 10.0.0.0/8 -j MASQUERADE
>
> if i do ping www.google.com from router source ip is 2.3.4.5, but if i do ping
> from local network source ip is 1.2.3.4 (i think it's wrong)
>
> with older kernel source ip is always set to 2.3.4.5
>
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
>
>
