From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: Documentation for IP_TRANSPARENT?
Date: Fri, 15 Oct 2010 21:40:19 +0200
Message-ID: <1287171619.32458.60.camel@bzorp.lan>
References: <cfd18e0f0811240806w541c85e9gafbcc80e8101f2b2@mail.gmail.com>
	 <1228828648.7631.75.camel@bzorp.balabit>
	 <AANLkTika83PJ_KkmE+3Rhi4JgTjEZHTDzV-hcyz_UCWB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: mtk.manpages@gmail.com
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <AANLkTika83PJ_KkmE+3Rhi4JgTjEZHTDzV-hcyz_UCWB@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-10-13 at 07:16 +0200, Michael Kerrisk wrote:
> Hello Bazsi
> 
> A long time after your mail, I've now added the text you supplied
> below. The changes are now available via git, and will be in
> man-pages-3.29. However, I have a few small questions that you can
> maybe clarify. See below.
> 
> On Tue, Dec 9, 2008 at 2:17 PM, Balazs Scheidler <bazsi@balabit.hu> wrote:
> > Hi,
> >
> > On Mon, 2008-11-24 at 11:06 -0500, Michael Kerrisk wrote:
> >> Hello Krisztian,
> >>
> >> Your 2.6.27 patch adds  the IP_TRANSPARENT socket option.  Could you
> >> please supply some documentation (plain text is fine) suitable for
> >> inclusion in the ip(7) man page.
> >
> > Although it was Krisztian who originally submitted the patches, but I
> > also did some things about them, so here I gave the documentation part a
> > spin.
> >
> > There are some other related options, that are undocumented right now,
> > so I tried to give documentation on those as well.
> >
> > IP_FREEBIND
> >        Enable binding to IP addresses that do not currently exist. When
> >        enabled on a TCP or UDP socket, the bind(2) call referencing a
> >        non-existing IP address will succeed. This functionality is useful
> >        if the specified IP address is dynamic (e.g. assigned to a PPP device)
> >        and is down at the time when the application is trying to bind to it.
> >        This setsockopt is the per-socket equivalent to ip_nonlocal_bind sysctl.
> >
> > IP_TRANSPARENT
> >        Enable transparent proxying on this socket. This socket option allows
> >        the calling application to bind to a non-local IP address and operate
> >        both as a client and a server with the foreign address as the local
> >        endpoint. NOTE: this requires that routing be set up in a way that
> >        packets going to the foreign address are routed through the tproxy box.
> 
> Can you say a few words explaining what is meant by "tproxy box".

tproxy box is the computer running the transparent proxy application,
ie. the one calling the IP_TRANSPARENT socket option.

> 
> Also, should one write "TProxy" here, analogous with "TProxy" below?

yes.

> 
> >        Enabling this socket option requires superuser privileges
> >        (more specifically the CAP_NET_ADMIN capability).
> >
> >        TProxy redirection with the iptables TPROXY target also requires that
> >        this option be set on the redirected socket.
> 
> In iptables(8), I find no mention of TPROXY. Is it just that the
> iptables(8) man page is not up to date?

AFAIR in iptables the man page is automatically generated from snippets
supplied with extensions.

Checking the iptables git tree, there's such a man page snippet for the
TPROXY target here:

http://git.netfilter.org/cgi-bin/gitweb.cgi?p=iptables.git;a=blob;f=extensions/libxt_TPROXY.man;hb=HEAD

I'm not 100% percent sure why it doesn't get into the iptables manual
page in your case. On my system, it seems to be included though:

$ man iptables | grep TPROXY
   TPROXY


> 
> > IP_RECVORIGDSTADDR
> >        Enables the IP_ORIGDSTADDR ancillary message in recvmsg(2) in which
> >        the kernel returns the original destination address of a datagram. The
> >        ancillary message contains a "struct sockaddr_in" instance.
> 
> Do you happen to know of any userspace test code that demonstrates the
> use of IP_RECVORIGDSTADDR?

Well, the one I have has too much cruft around it and many layers of
indirection, not really good for a sample code.

Pattern-wise it is the same as IP_RECVTTL, e.g. you set
IP_RECVORIGDSTADDR via setsockopt and then you get an ancillary message
with recvmsg() with the cmsg_level == IPPROTO_IP and cmsg_type ==
IP_ORIGDSTADDR

There's a similar sample in cmsg(3)

If you still need a sample, let me know and I'll cook something up.

> 
> Thanks for this documentation, and sorry it took so long to make its
> way into man-pages.

No problem :) I could use these interfaces ever since :)

-- 
Bazsi


