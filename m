From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sun, 19 Sep 2004 11:20:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919.112009.92851216.yoshfuji@linux-ipv6.org>
References: <20040918220211.GI6005@sunbeam.de.gnumonks.org>
	<20040918180647.6be57884.davem@davemloft.net>
	<20040919.111141.42341294.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com, usagi-users@linux-ipv6.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040919.111141.42341294.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040919.111141.42341294.yoshfuji@linux-ipv6.org> (at Sun, 19 Sep 2004 11:11:41 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20040918180647.6be57884.davem@davemloft.net> (at Sat, 18 Sep 2004 18:06:47 -0700), "David S. Miller" <davem@davemloft.net> says:
> 
> > On Sun, 19 Sep 2004 00:02:11 +0200
> > Harald Welte <laforge@gnumonks.org> wrote:
> > 
> > > Now I'm stuck with another issue:  The interfaces suddenly no logner
> > > get any link-local addresses:
> > 
> > Probably due to this change.
> > 
> > # This is a BitKeeper generated diff -Nru style patch.
> > #
> > # ChangeSet
> > #   2004/09/10 14:50:26-07:00 yoshfuji@linux-ipv6.org 
> > #   [IPV6]: Deprecate all-on-link assumption
> 
> I don't think so.

And, that code was run after the link-local address assignment.
What we did was:

 1. Try to assign link-local address.
    - start DAD
    - wait a while
 2. If DAD ends with no duplicated addresses, 
    try to search neighbor routers.
    - send RS
    - wait a while
 3. If no routers present, add "all-on-link" route.

The patch deletes the last one (3).
and it should not be something to do with the link-local address assignment.

--yoshfuji
