From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: UDP sockets bound to ANY send answers with wrong src ip address
Date: Wed, 9 Jun 2004 15:45:23 +0300
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200406091545.23674.vda@port.imtp.ilyichevsk.odessa.ua>
References: <Pine.LNX.4.44.0406091511350.6279-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com, <linux-net@vger.kernel.org>,
	<davem@redhat.com>, <yoshfuji@linux-ipv6.org>, <pekkas@netcore.fi>,
	<jmorris@redhat.com>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265763AbUFINBG@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0406091511350.6279-100000@l>
List-Id: netdev.vger.kernel.org

On Wednesday 09 June 2004 15:18, Julian Anastasov wrote:
> Hello,
>
> On Wed, 9 Jun 2004, Denis Vlasenko wrote:
> > I observe that UDP sockets listening on ANY
> > send response packets with ip addr derived from
> > ip address of interface which is used to send 'em
> > instead of using dst ip address of client's packet.
> >
> > I was bitten by this with DNS and NTP.
>
> 	The problem is in the apps. You have some options:
>
> - use sockets listening on ANY and using sendmsg with IP_PKTINFO
> and providing the desired src IP in ipi_spec_dst
>
> - you can also create many listener sockets listening on
> particular src IP and to reply using the socket where the
> request is received, because the kernel does not know any
> association between request and reply packets if the listener
> is bound to ANY.

Aha! That's why ntpd is so eager to bind to everything imaginable!
(Which does not help BTW with non-permanent interfaces like
ppp, tun etc).

/me googling for that IP_PKTINFO thing...
--
vda
