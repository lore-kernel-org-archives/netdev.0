From: Michael Leun <lkml20100708@newton.leun.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (after using openvpn)
Date: Thu, 5 Aug 2010 12:13:48 +0200
Message-ID: <20100805121348.38ac91ce@xenia.leun.net>
References: <loom.20100708T183152-326@post.gmane.org>
	<20100709235744.GA12752@kroah.com>
	<20100710101540.2799c9ef@xenia.leun.net>
	<20100710140800.GA20424@kroah.com>
	<20100710165208.59272ae6@xenia.leun.net>
	<20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
	<20100805001105.5a3453ed@xenia.leun.net>
	<m1lj8l29zm.fsf@fess.ebiederm.org>
	<20100805112538.60a46cb1@xenia.leun.net>
	<m1y6clz8ta.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1y6clz8ta.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 05 Aug 2010 02:51:29 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Michael Leun <lkml20100708@newton.leun.net> writes:
> 
> > Hi,
> >
> > On Wed, 04 Aug 2010 17:12:29 -0700
> > ebiederm@xmission.com (Eric W. Biederman) wrote:
> >
> > First, thank you very much for picking that up (and, of course, for
> > your work at linux in general).
> >
> >
> >> > # > unshare -n /bin/bash
> >> > # > # how to setup veth device pair to get connectivity into
> >> > namespace not shown here # > openvpn --config some.config
> >> > [ running some traffic over vpn device not shown here ]
> >> > ^c # stopping openvpn
> >> > # > lsof -i
> >> > # > netstat -an
> >> > Active Internet connections (servers and established)
> >> > Proto Recv-Q Send-Q Local Address           Foreign Address
> >> > State Active UNIX domain sockets (servers and established)
> >> > Proto RefCnt Flags       Type       State         I-Node Path
> >> > # > ps ax|grep openvpn|grep -v grep
> >> > # > # cannot find anything that suggests there is anything left
> >> > from that openvpn session # > exit # logging out from shell in
> >> > network namespace
> >> >
> >> > Now I get
> >> >
> >> > Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for
> >> > lo to become free. Usage count = 3 [repeated]
> >> 
> >> How many times?
> >
> > Unfortunately looks like indefinitely. Never watched longer so far
> > (rebooted soon), but I'm seeing this message now repeated every 10
> > secs for ~10 minutes on a idle system.
> 
> Ugh.  A real bug then.  These can be a pain to track down and fix. I
> think the last one of these I tracked down took a couple of weeks.  I
> will start digging in when I get back from vacation.

As I said, if I can do anything to support you, testing or so, please
let me know.

Until then: Have a great vacation!

> > Additionally when testing this I found another one (by accident
> > started my firewall script in that namespace...) - using netfilter
> > RECENT makes it barf. Stripped down to the essentials it looks like
> > this:
> 
> Micheal this is on 2.6.35?

Yup - almost vanilla 2.6.35, only patches for aufs (union filesystem)
got in.

> Alexey can you look at this BUG_ON?  It looks like there has been a
> regression or you missed something when you did the netns conversion
> of xt_recent.
> 
> 
> >> # unshare -n /bin/bash
> >> # iptables -I INPUT -d 1.2.3.4 -m recent --name BLA --set
> >> # exit
> >
> > Aug  5 11:19:47 doris kernel: [  218.420238] ------------[ cut
> > here ]------------ Aug  5 11:19:47 doris kernel: [  218.420256]
> > kernel BUG at net/netfilter/xt_recent.c:609! Aug  5 11:19:47 doris
[...]

-- 
MfG,

Michael Leun
