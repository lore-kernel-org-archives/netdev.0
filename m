From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: HTB accuracy on 10GbE
Date: Mon, 2 Nov 2009 12:53:45 -0800
Message-ID: <20091102125345.3c39c42e@nehalam>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
	<4AEEFE2E.7090706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ryousei Takano <ryousei@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44327 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932328AbZKBUyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 15:54:17 -0500
In-Reply-To: <4AEEFE2E.7090706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Nov 2009 16:43:42 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Ryousei Takano wrote:
> > Hi Stephen and all,
> > 
> > I have observed a HTB accuracy problem on the Linux kernel 2.6.30 and
> > the Myri-10G 10 GbE NIC.
> > HTB can control the transmission rate at Gigabit speed, however it can
> > not work well at 10 Gigabit speed.
> > 
> > I asked Stephen this problem at Japan Linux Symposium.  He mentioned a
> > HTB bug related to the timer granularity.
> > I want to know what is happen, and what should be do for fixing it.
> > 
> > Any comments and suggestions will be welcome.
> > 
> > For more detail, please see the following page:
> > http://code.google.com/p/pspacer/wiki/HTBon10GbE
> 
> This is not an easy problem to fix. Userspace, the kernel and the
> netlink API use 32 bit for timing related values, which is too small
> to use more than microsecond resolution. All of them need to be
> converted to use bigger types, additionally some kind of compatibility
> handling to deal with old iproute versions still using microsecond
> resolution is required.

The existing API is a legacy mish-mash. The field is limited to 32 bits,
but it might be possible to use a finer scale.

Maybe if kernel advertised finer resolution through /proc/net/psched
then table could be finer grained. This would maintain compatibility
between kernel and user space. You would need to have new kernel and
new iproute to get nanosecond resolution but older combinations would
still work.

The downside is that by using nanosecond resolution the rates are upper
bounded at 4.2seconds / packet.

