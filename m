From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 and netlink
Date: Fri, 26 Nov 2004 10:14:36 +0900 (JST)
Message-ID: <20041126.101436.57039674.yoshfuji@linux-ipv6.org>
References: <200411232322.50083.hasso@estpak.ee>
	<20041123134257.5c45f5fc.davem@davemloft.net>
	<200411252313.30348.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hasso@estpak.ee
In-Reply-To: <200411252313.30348.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200411252313.30348.hasso@estpak.ee> (at Thu, 25 Nov 2004 23:13:30 +0200), Hasso Tepper <hasso@estpak.ee> says:

> David S. Miller wrote:
> > On Tue, 23 Nov 2004 23:22:50 +0200
> 
> My first letter didn't end in list, seems. Sorry if most of this info will 
> be duplicate.
> 
> > Hasso Tepper <hasso@estpak.ee> wrote:
> > > While debugging IPv6 RIB in Quagga routing software I discovered some
> > > issues with kernel rtnetlink messages.
> > >
> > > 1) RTM_NEWROUTE message with prefix ff00::/8 (if interface goes up or
> > > down) is sent with rtm_type set to RTN_UNICAST. It's multicast route,
> > > so why not RTN_MULTICAST? Is it bug?
> >
> > What kernel version?  I remember fixing this bug.
> > We should not be emitting rtnetlink messages for
> > these any more.
> 
> Although my main production platform is 2.4.28, I tested with 2.6.9 (with 
> patch added from http://oss.sgi.com/archives/netdev/2004-11/msg00558.html) 
> as well. Is this too old already?
> 
> I tested now with 2.6.10-rc2-bk8 as well and all these bugs are still there. 
> RTM_NEWROUTE messages are sent for both, ff00::/8 and fe80::/64 with 
> rtm_type set to RTN_UNICAST and rtm_protocol set to RTPROT_BOOT.

Okay, I eat this report.

Another fact: In IPv4, RTPROT_BOOT is set if it is configured 
if route is configued via ip_rt_ioctl().
If is called from ipconfig or inet_ioctl().
RTPROT_BOOT should be set only when it is set via ipconfig, I think.

Back to IPv6. Do we really need RTPROT_BOOT in IPv6?
I don't think so.

Because we don't know if the interface was brought up
by kernel during boot (by ipconfig), so 
it is not trivial.


> hasso:/home/hasso# ip -6 route | grep 3ffe
> hasso:/home/hasso# ip -6 addr add 3ffe::1/64 dev eth0
> hasso:/home/hasso# ip -6 route | grep 3ffe
> 3ffe::/64 dev eth0  metric 256  mtu 1500 advmss 1440 metric10 64
> hasso:/home/hasso# ip -6 addr del 3ffe::1/64 dev eth0
> hasso:/home/hasso# ip -6 route | grep 3ffe
> 3ffe::/64 dev eth0  metric 256  mtu 1500 advmss 1440 metric10 64
> hasso:/home/hasso#

I think this is a bug.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
