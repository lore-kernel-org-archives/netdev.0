From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: more on "tcp_window_scaling degrades performance"
Date: Wed, 28 Jul 2004 17:37:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <754869571.20040728173740@dns.toxicfilms.tv>
Reply-To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I was posting about problems with TCP lately.

It might still be a problem with the kernel and not the firewall.
I am having problems with machines on the same LAN.
Here is what I do to reproduce (sometimes works, sometimes not)
# ssh user@host.on.lan
[login]
# su -
[su login]
# iptraf
[choosing detailed interface statistics on a busy interface]
It shows the statistics nice, but after a few seconds it
gets seriously lagged, even my keystrokes to exit work with a lag.

It also happens eg. when removing a lot of files in midnight
commander via ssh. FTP transfers also suffer

I am not doing andy filtering or mangling on the way between the
hosts.

I have this behaviour with a 2.6.8-rc1 kernel and 2.6.7+ kernels
and alos with 2.6.8-rc1 and 2.4.26 kernel.
I suspect changes in 2.6.7-8 devel cycle to have changed something
bad.

I made a tcpdump -v (human readable) of the problematic connection:
http://www.soltysiak.com/tcp_ws.txt

It is a connection between 150.254.37.24 (2.6.8-rc1) and 150.254.36.4
(2.4.26) Same effects are seen between 150.254.37.24 and 150.254.37.3
so it is not a router issue. Follow what's below:

16:17:01.669931: logging on with ssh, typing commands, waiting for
                 the problem to appear.
                 Notice tcpdump's bad tcp checksums at the beginning!
16:17:19.195772: 2.6.8-rc1 kernel sends the first packet with a very
                 small win and we have a problem. (is it SWS?)
in the mean time i am trying to get out of iptraf and log out

16:17:40.372086: closing the connection, notice the tcp bad checksums
                 again.

2.4.26 sysctls are as default
2.6.8 sysctls are as default except that:
tcp_windows_scaling is 0
tcp_bic is 0
tcp_sack is 0
tcp_fack is 0

I tried to zero these options to fix the problem, although with these
enabled the problems still exists.

What would you suggest?

Regards,
Maciej

 
