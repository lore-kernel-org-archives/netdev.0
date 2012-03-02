From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 2 Mar 2012 17:08:23 +0000
Message-ID: <20120302170823.7117821b@pyramind.ukuu.org.uk>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
	<20120301.170848.432407217191581288.davem@davemloft.net>
	<CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
	<20120302.035509.1994457175982020283.davem@davemloft.net>
	<4F509274.9060302@collabora.co.uk>
	<1330694031.2469.15.camel@edumazet-laptop>
	<4F50F6AA.9050909@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	ying.xue@windriver.com, luiz.dentz@gmail.com,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F50F6AA.9050909@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 2- The transport layer used by D-bus is not performance sensitive
> basically due:
> 
> a) high number of context switches required to send messages between peer.

This is a user space design issue. The fact dbus wakes up so much
stuff wants fixing at the dbus level.

> b) the D-bus daemon doing the routing and being a bottleneck of the whole.

This is a userspace design issue.

> c) amount of messages copied between kernel space and user space.

This is mostly a userspace design issue and fixing a would fix much of c
because you wouldn't keep sending people crap they didn't need.

You've already got multicast facilities in kernel (if dbus must work by
shouting not state change subscription like saner setups), and you've got
BPF filtering facilities to try and cure some of the wakeups even doing
multicast.

Beyond that I don't see what the kernel can do given its mostly an
architectural problem.

Your model appears to be "since its causing enormous amounts of work we
should do the work faster". The right model would appear to me to be "We
shouldn't cause enormous amounts of work"

Alan
