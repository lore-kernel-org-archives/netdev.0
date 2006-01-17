From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch] networking ipv4: remove total socket usage count from
 /proc/net/sockstat
Date: Tue, 17 Jan 2006 10:18:57 +0900 (JST)
Message-ID: <20060117.101857.91620091.yoshfuji@linux-ipv6.org>
References: <bdfc5d6e0601161255w4e1a6ac5oaa6844a6e1bbd0aa@mail.gmail.com>
	<9a8748490601161308g5f941c30o870042e6d9811c58@mail.gmail.com>
	<bdfc5d6e0601161433g1c51dd4dpbc5da4cd7581d5d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, rlrevell@joe-job.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751324AbWAQBSJ@vger.kernel.org>
To: andy@greyhouse.net
In-Reply-To: <bdfc5d6e0601161433g1c51dd4dpbc5da4cd7581d5d6@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <bdfc5d6e0601161433g1c51dd4dpbc5da4cd7581d5d6@mail.gmail.com> (at Mon, 16 Jan 2006 17:33:59 -0500), Andy Gospodarek <andy@greyhouse.net> says:

> On 1/16/06, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> > >
> > Maybe if you described "your current problem" someone could suggest a
> > solution...
> >
> 
> Sure, I'd be glad to.  If I add up all the entries from the procfiles
> (in /proc/net) on my system
:
> I find there are a total of 54 sockets open on my system.
> 
> Now this seems to differ from the value in /proc/net/sockstat:
> # cat sockstat
> sockets: used 59
:
> So we are off by 5.  I added some code around the stat collection used
> in sockstat to get more detailed info about those sockets and the
> output is here.  The values are family[protocol family][socket
> family].
:
> Total = 59
> 
> All of these numbers match up with what we saw above, except the
> INET/RAW and INET6/RAW sockets.  It seems they aren't being counted
> correctly -- which accounts for the 5 missing sockets.  The
> decrementing of these values is in sock_release() and seems to get
> done correctly other times RAW sockets are created, but not for the 5
> sockets in question.

This is because we have several internal unhashed raw sockets in
kernel, which are not counted in the "raw" entry, but in "sockets."

--yoshfuji
