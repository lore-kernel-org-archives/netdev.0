From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: strategy hander for net.ipv6.conf.*.forwarding
 (is Re: problem setting net.ipvX.conf.all.forwarding via sysctl() system
 call)
Date: Sat, 9 Aug 2003 01:08:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809010845.01ebcbe9.davem@redhat.com>
References: <20030803154427.GA12926@wsx.ksp.sk>
	<20030808.175030.19527061.yoshfuji@linux-ipv6.org>
	<20030808093704.GA18131@wsx.ksp.sk>
	<20030808.185135.112441851.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jan.oravec@6com.sk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030808.185135.112441851.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 08 Aug 2003 18:51:35 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <20030808093704.GA18131@wsx.ksp.sk> (at Fri, 8 Aug 2003 11:37:04 +0200), Jan Oravec <jan.oravec@6com.sk> says:
> 
> > On Fri, Aug 08, 2003 at 05:50:30PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > 
> > > +	*valp = new;
> > > +	if (valp != &ipv6_devconf.forwarding &&
> > > +	    valp != &ipv6_devconf_dflt.forwarding) {
> > > +		struct inet6_dev *idev = (struct inet6_dev *)table->extra1;
> > > +		if (!idev)
> > > +			return -ENODEV;
> > > +		addrconf_forward_change(idev);
> > > +	}
> > > +	return 0;
> > > +}
> > 
> > Shouldn't we set ipv6_devconf_dflt.forwarding and call
> > addr_forward_change(NULL) in case that valp==&ipv6_devconf.forwarding?
> 
> Oh, You're right. Here's the revised one:

As I mentioned for the ipv4 forwarding sysctl bug fix,
if you will set table->data yourself you should return
> 0 (for example "1") from your strategy handler.

The patch looks fine otherwise.

Please fix this, thank you.
