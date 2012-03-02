From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 02 Mar 2012 10:27:16 +0100
Message-ID: <4F509274.9060302@collabora.co.uk>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com> <20120301.170848.432407217191581288.davem@davemloft.net> <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com> <20120302.035509.1994457175982020283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: luiz.dentz@gmail.com, eric.dumazet@gmail.com,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	ying.xue@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120302.035509.1994457175982020283.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/2012 09:55 AM, David Miller wrote:
> From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
> Date: Fri, 2 Mar 2012 10:39:24 +0200
> 
>> Like I said before there is many projects using AF_UNIX as IPC
>> transport, the documentation actually induces people to use for this
>> purpose, and many would benefit from being able to do multicast.
> 
> You can't have it both ways.
> 
> If it's useful for many applications, then many applications would
> benefit from a userland library that solved the problem using
> existing facilities such as IP multicast.
> 
> If it's only useful for dbus that that absoltely means we should
> not add thousands of lines of code to the kernel specifically for
> that application.
> 

You are right that D-bus is the only one that will use it but D-bus is
more than an application is an IPC system that is used for almost every
single application that runs on your Linux desktop.

> So either way, kernel changes are not justified.

Yes, you are right that packets drops, out-of-order delivery and flow
control could be handled in another layer (i.e: the D-bus library in
user-space).

Also I won't argue about performance since we did some stress test and
found that AF_INET, AF_UNIX and AF_NETLINK performs very similar for
multicast.

> Stop reinventing the wheel, use facilities that exist already.

We are the most interested in using a facility already found in the
kernel, we will try ZeroMQ as Stephen suggested and TIPC but really
didn't find an IPC mechanism that fits our needs. The most important
issue right now is the fd passing for D-bus application doing
out-of-band communication.

Another approach that we are trying is to use Netlink sockets using the
Generic Netlink kernel API and develop a kernel module that does the
routing. That way if you don't accept our code at least it will be
easier for us to maintain. Not sure if netlink supports fd passing though.

Do you think that a simpler AF_UNIX multicast implementation without the
locking to guarantee order delivery and the flow control that blocks the
sender can be resend to you to reconsider merging it?

Regards,
Javier
