From: Michael Leun <lkml20100708@newton.leun.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (adding ipv6 address to interface)
Date: Thu, 21 Oct 2010 17:15:32 +0200
Message-ID: <20101021171532.54af5e97@xenia.leun.net>
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
	<20100805134707.0442a7b1@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100805134707.0442a7b1@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

unfortunately the bug described below originally reported in 2.6.35-rcX
is still there in 2.6.36.

Is there anything I might do to help fix it (besides fixing it myself,
I do not have the knowhow)?

On Thu, 5 Aug 2010 13:47:07 +0200
Michael Leun <lkml20100708@newton.leun.net> wrote:

[...]
> Putting an ipv6 address on a device seems to be the trigger:
> 
> OrigNS > # ip link add type veth
> OrigNS > # ip link set dev veth0 up
> OrigNS > # unshare -n /bin/bash
> NewNS > # echo $$
> <SomePID>
> OrigNS > # ip link set dev veth1 netns <SomePID> # this, of course is
> on a different terminal NewNS > # ip link set dev veth1 up
> NewNS > # ip -6 addr add dev veth1 fd50:dead:beef::1/64
> NewNS > # exit
> 
> Yields
> 
> kernel: unregister_netdevice: waiting for veth1 to become free. Usage
> count = 3
> 
> Oh - its veth1 this time, not lo - add an "ip link set up dev lo" in
> the above scenario just after the unshare, and you get the message
> with lo.
> 
> One might ask, if
> 
> > # unshare -n /bin/bash
> > # ip link set up dev lo
> > # ip -6 addr add dev veth1 fd50:dead:beef::1/64
> > # exit
> 
> also does the trick, so I tried it - and it does NOT.
> 
> In the above scenario, not setting veth0 and veth1 up also makes it
> not happen. Only setting veth1 up also is not enough (seems to need
> to be "really up" what as you shurely know with veth is only the case
> when both sides are up).
> 
> I hope, this makes it somewhat easier to track that down.


-- 
MfG,

Michael Leun
