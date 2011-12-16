From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 12:30:23 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1112161225490.28554@router.home>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>     <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>     <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>    <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
  <alpine.DEB.2.00.1112161043080.26765@router.home>   <1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <alpine.DEB.2.00.1112161053030.26765@router.home>  <1324055686.25554.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1112161128060.26765@router.home> <1324058911.25554.82.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1802685353-1324060224=:28554"
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:46221 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760218Ab1LPSa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:30:26 -0500
In-Reply-To: <1324058911.25554.82.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1802685353-1324060224=:28554
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 16 Dec 2011, Eric Dumazet wrote:

> Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 11:29 -0600, Christoph Lameter a=
 =C3=A9crit :
>
> > I have some latency critical processes here and I wish I could get
> > networking in general off the processor where the latency sensitive stu=
ff
> > is running should that process decide to do some calls that cause netwo=
rk
> > I/O.
> >
> > Traditional networking is a slow process these days.
>
>
> Most of the slow process is in the process scheduler actually and cache
> line misses in large TCP structures, but also in many layers (Qdisc...),
> not counting icache footprint.
>
> We slowly improve things, but its always a tradeoff (did I said code
> bloat ?)
>
> If you have dedicated network thread(s) in your application, bound to
> the right cpu(s), then all network stack can be run on the cpus you
> decide [ Also needs using correct irq affinities for the NIC interrupts]
>
> This means your latency critical threads should delegate their network
> IO (like disk IO) to other threads, _and_ avoid being blocked in
> scheduler land.

Right. So why can the OS not do this? If I do read/write via a socket then
do the usual processing as much as possible on the current cpu. Never
schedule any operations later on this cpu. Run scheduled tasks only on the
cpus that are allowed to be used for network stuff.

> Given the nature of socket api, I am not sure adding a layer to
> transparently delegate network IO to a pool of dedicated cpus would be a
> win.

The problem is that the socket layer is drag for low latency apps. They
only use the socket api in non latency critical sections. If an action in
a non latency critical section causes the processor to be interrupted
later in a latency critical section then this is not good.


---1463811839-1802685353-1324060224=:28554--
