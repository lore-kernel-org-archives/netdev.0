From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig schedule fix
Date: Tue, 23 Nov 2004 15:45:13 -0800
Message-ID: <20041123154513.0c950033.davem@davemloft.net>
References: <aec7e5c3041123145030b75d14@mail.gmail.com>
	<20041123151855.1864659a.davem@davemloft.net>
	<aec7e5c304112315426594dc72@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Magnus Damm <magnus.damm@gmail.com>
In-Reply-To: <aec7e5c304112315426594dc72@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2004 00:42:17 +0100
Magnus Damm <magnus.damm@gmail.com> wrote:

> On Tue, 23 Nov 2004 15:18:55 -0800, David S. Miller <davem@davemloft.net> wrote:
> > On Tue, 23 Nov 2004 23:50:35 +0100
> > 
> > 
> > Magnus Damm <magnus.damm@gmail.com> wrote:
> > 
> > > This simple patch makes the DHCP/BOOTP/RARP code sleep with
> > > schedule_timeout() instead of hogging the cpu with cpu_relax() in a
> > > loop. This comes handy when a guest kernel is booted inside QEMU.
> > > Without the patch, the host operating system will consume cpu time
> > > busy waiting.
> > 
> > There are two similar loops involving CONF_PRE_OPEN and CONF_POST_OPEN,
> > you may wish to hit those while you're at it.
> 
> Huh? You mean _removing_ the timeouts involving CONF_PRE/POST_OPEN? I
> thought my patch converted all busy waits into schedule_timeout()...
> What am I missing?

No, not removing them, but transforming them likewise into
schedule_timeout() calls.
