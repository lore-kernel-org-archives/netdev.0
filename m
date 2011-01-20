From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: getifaddrs
Date: Thu, 20 Jan 2011 13:57:13 +0100
Message-ID: <20110120125713.GB743@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

I am in the process of adding j1939 support in the linux kernel.
J1939 is a protocol on CAN, with addressing support. Therefore,
I'm tweaking in iproute2 as well, to extend the
$ ip address
output.

I have in kernel space
	rtnl_register(PF_CAN, RTM_GETADDR, NULL, j1939_nl_dump_ifaddr);
This 'j1939_nl_dump_ifaddr' does not dump 'struct sockaddr *', but
an ad-hoc format.

After I get a basic setup working, I tried calling 'getifaddrs'.
If I do 'getifaddrs', this callback is called, but
I do not understand how glibc (or any other libc) is capable of transforming
the rtnetlink address info into proper 'struct sockaddr_can *'.

I looked at AF_INET & AF_DECnet, and it seems I'm not supposed to
dump a 'struct sockaddr_can' over rtnetlink. Is 'getifaddrs' then doomed
to only work for INET addresses only?

Any idea's?

Thanks,
Kurt
