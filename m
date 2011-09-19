From: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Mon, 19 Sep 2011 08:19:40 -0400
Message-ID: <20110919121940.GA19942@synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I noticed what appears to be a discrepancy between the ip(7) man page
and the kernel code with regards to the IP DF flag for UDP sockets.

The man page says that "The don't-fragment flag is set on all outgoing
datagrams" and that the ip_no_pmtu_disc sysctl affects only SOCK_STREAM
sockets. This is quickly disproved by doing:
echo 1 > /proc/sys/net/ipv4/ip_no_pmtu_disc
firing up netcat and looking at a few outgoing udp packets in wireshark
(they don't have the DF flag set).

1) in the words of `man 7 ip`:
IP_MTU_DISCOVER (since Linux 2.2)
      Set or receive the Path MTU Discovery  setting  for  a  socket.
      When  enabled, Linux will perform Path MTU Discovery as defined
      in RFC 1191 on this socket.  The don't-fragment flag is set  on
      all  outgoing datagrams.  The system-wide default is controlled
      by the /proc/sys/net/ipv4/ip_no_pmtu_disc file for  SOCK_STREAM
      sockets, and disabled on all others.

This is the text present in the latest version of the online manpages,
http://webcache.googleusercontent.com/search?q=cache:http://www.kernel.org/doc/man-pages/reporting_bugs.html&ie=UTF-8

2) in net/ipv4/af_inet.c:inet_create():
	if (ipv4_config.no_pmtu_disc)
		inet->pmtudisc = IP_PMTUDISC_DONT;
	else
		inet->pmtudisc = IP_PMTUDISC_WANT;

and pmtudisc is left alone from there on for UDP sockets.

What should be adjusted, the man page or the code?

Thanks,
-Ben
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
