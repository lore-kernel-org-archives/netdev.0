From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 15:09:17 +0300
Message-ID: <200808271509.18529.denys@visp.net.lb>
References: <200808220457.40892.denys@visp.net.lb> <48B46B48.7030609@cosmosbay.com> <20080826205158.GA15266@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_uPUtIK8vFW3CqnH"
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:56466 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565AbYH0MKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 08:10:49 -0400
In-Reply-To: <20080826205158.GA15266@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_uPUtIK8vFW3CqnH
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 26 August 2008, Evgeniy Polyakov wrote:
> On Tue, Aug 26, 2008 at 10:44:56PM +0200, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > >Do you have any packet sockets in this system? Like running dhcp daemon?
No, nothing at all.
> >
> > Another way to see this problem can be to start a sniffer on the machine,
> > even with a restrictive pcap filter, to check if performance change or
> > not. (It should decrease)
Yes, when i run tcpdump even without promisc at peak time, machine will be 
almost dead. Transit traffic will be 100ms+. I know that it is timestamping 
packets. Same almost for any libpcap app.

>
> Or just check /proc/net/packet iirc.
> Anyway, having at least one packet socket ends up with timestamping of
> each packet, so you will get fair load of getnstimeofday() in that case.
There is very short list of tasks. Attached. 
/proc/net/packet clean, nothing there.

>
> > For example, I believe that running "ping" could have the same effect
> > (increasing netstamp_needed variable : every incoming packet has to be
> > timestamped)
Even answering icmp timestamp request will take resources.
> >
> > So beware of pings, traceroute and other networking tools...
When i am measuring performance - they are all off.
>
> Yup, this innocent toys can end up with this such behaviour on modern
> highly loaded machines.



--Boundary-00=_uPUtIK8vFW3CqnH
Content-Type: text/plain;
  charset="iso-8859-1";
  name="tasks.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="tasks.txt"

tcp        0      0 127.0.0.1:2600          0.0.0.0:*               LISTEN     3167/zebra
tcp        0      0 0.0.0.0:2601            0.0.0.0:*               LISTEN     3167/zebra
tcp        0      0 0.0.0.0:2602            0.0.0.0:*               LISTEN     3174/ripd
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     3549/sshd
tcp        0      0 194.146.153.17:22       194.146.154.161:37549   ESTABLISHED11593/sshd
tcp        0      0 194.146.153.17:22       192.168.0.92:45891      ESTABLISHED11803/sshd
tcp        0      0 127.0.0.1:42537         127.0.0.1:2600          ESTABLISHED3174/ripd
tcp        0      0 194.146.153.17:22       194.146.153.18:51810    ESTABLISHED11799/sshd
tcp        0      0 127.0.0.1:2600          127.0.0.1:42537         ESTABLISHED3167/zebra
udp        0      0 0.0.0.0:520             0.0.0.0:*                          3174/ripd
udp        0      0 0.0.0.0:161             0.0.0.0:*                          3194/snmpd
udp        0      0 0.0.0.0:67              0.0.0.0:*                          3207/udhcpd
udp   111360      0 0.0.0.0:49619           0.0.0.0:*                          2449/syslogd

--Boundary-00=_uPUtIK8vFW3CqnH--
