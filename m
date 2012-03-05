From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Mon, 05 Mar 2012 16:11:16 +0100
Message-ID: <4F54D794.5090903@collabora.co.uk>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com> <20120301.170848.432407217191581288.davem@davemloft.net> <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com> <20120302.035509.1994457175982020283.davem@davemloft.net> <4F509274.9060302@collabora.co.uk> <1330694031.2469.15.camel@edumazet-laptop> <4F50F6AA.9050909@collabora.co.uk> <20120302170823.7117821b@pyramind.ukuu.org.uk> <CABBYNZKhoT-POaaSvHoNLXU+hkPCiY_eqjEqDgzCqq4RvEvNXg@mail.gmail.com> <mj+md-20120305.140318.15543.albireo@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	ying.xue@windriver.com, rodrigo.moya@collabora.co.uk,
	javier@collabora.co.uk, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>
To: Martin Mares <mj@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <mj+md-20120305.140318.15543.albireo@ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/05/2012 03:05 PM, Martin Mares wrote:
> Hi!
> 
>> Please check the link above and tell me if that different than the
>> model you suggested using BPF, apparently we are talking about the
>> very same solution but the implementation detail are getting in the
>> way because a lot of code was added.
> 
> ...
> 
> First of all, you should come up with some real data confirming that
> the problem you are trying to solve really exist -- i.e., that in some
> real (and sensible) setup, routing all messages through DBUS daemon
> is a bottleneck.
> 
> 				Have a nice fortnight

We still don't have performance numbers for D-bus using AF_UNIX
multicast since our D-bus daemon branch is still not stable. But Alban
did some tests for the first approach (creating a new socket address
family AF_DBUS) and the performance gain was x1.8 for KVM/i386 and x3
for N900/ARM.

Alban's blog entry can be found here:
http://alban-apinc.blogspot.com/2011/12/d-bus-in-kernel-faster.html

Yes, D-bus has many architectural flaws that has to be addressed. The
out-of-order delivery requirement maybe is not even important in real
world and the control flow is something that probably we can fix in
user-space too. That every message has to pass through the D-bus daemon
is something that can also be fixed without requiring any kernel
modification.

But there is one problem that we can't solve without Linux kernel
support. The fact that multicast messages have to be directly sent to
the receivers.

The problem is that Linux lacks of an easy IPC mechanism to send
multicast messages to processes in the same machine. We can use UDP
multicast over IP but even when the sending/receiving performance is
similar to our AF_UNIX multicast implementation, the connection setup is
much more complex.

We will investigate if we can use Netlink sockets as an multicast IPC
mechanism even when it is designed for the kernel-space/user-space use
case and not well suited to user-space/user-space communication.

Best regards,
Javier
