From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] ipconfig schedule fix
Date: Wed, 24 Nov 2004 01:02:33 +0100
Message-ID: <aec7e5c3041123160259df1594@mail.gmail.com>
References: <aec7e5c3041123145030b75d14@mail.gmail.com>
	 <20041123151855.1864659a.davem@davemloft.net>
	 <aec7e5c304112315426594dc72@mail.gmail.com>
	 <20041123154513.0c950033.davem@davemloft.net>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041123154513.0c950033.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Nov 2004 15:45:13 -0800, David S. Miller <davem@davemloft.net> wrote:
> On Wed, 24 Nov 2004 00:42:17 +0100
> 
> 
> Magnus Damm <magnus.damm@gmail.com> wrote:
> 
> > On Tue, 23 Nov 2004 15:18:55 -0800, David S. Miller <davem@davemloft.net> wrote:
> > > On Tue, 23 Nov 2004 23:50:35 +0100
> > >
> > >
> > > Magnus Damm <magnus.damm@gmail.com> wrote:
> > >
> > > > This simple patch makes the DHCP/BOOTP/RARP code sleep with
> > > > schedule_timeout() instead of hogging the cpu with cpu_relax() in a
> > > > loop. This comes handy when a guest kernel is booted inside QEMU.
> > > > Without the patch, the host operating system will consume cpu time
> > > > busy waiting.
> > >
> > > There are two similar loops involving CONF_PRE_OPEN and CONF_POST_OPEN,
> > > you may wish to hit those while you're at it.
> >
> > Huh? You mean _removing_ the timeouts involving CONF_PRE/POST_OPEN? I
> > thought my patch converted all busy waits into schedule_timeout()...
> > What am I missing?
> 
> No, not removing them, but transforming them likewise into
> schedule_timeout() calls.

Yeah, but isn't the patch already doing that? I tried to find more
occurances of CONF_PRE/POST_OPEN in the
linux-2.6.10-rc2-mm3/net/ipv4/ipconfig.c but I think the patch covers
all of them. Please point out what I am missing, maybe it is getting
too late for me know...

/ magnus
