From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Mon, 13 Jan 2014 16:08:22 -0500
Message-ID: <CABrhC0=9ff8aLG4y4gxiGrGBBHvdcWD2pCC3wyLTveKHRySg4A@mail.gmail.com>
References: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
	<20140113.112504.922587457597727366.davem@davemloft.net>
	<CABrhC0n2AgHNQg-2nQk-sx1=k2=TvmGa+2seqoNT=XyDdz59yg@mail.gmail.com>
	<20140113204253.GI6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: John Heffner <johnwheffner@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	steffen.klassert@secunet.com, fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:65500 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaAMVIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 16:08:23 -0500
Received: by mail-wg0-f41.google.com with SMTP id n12so3238590wgh.4
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 13:08:22 -0800 (PST)
In-Reply-To: <20140113204253.GI6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 3:42 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mon, Jan 13, 2014 at 02:35:31PM -0500, John Heffner wrote:
>> My only comment would be not to look to me as the only source of
>> reason not to include this change.  I've been largely disconnected
>> from Linux development for several years and don't have time to get
>> into a protracted discussion on this topic.
>>
>> FWIW, I still have doubts as to whether this is the best approach to
>> solving the underlying problem.  I still haven't heard any reason why
>> firewall rules and other administrative best practices, such as using
>
> Because we currently cannot easily filter icmp payloads and check whether
> it is in a response for a local socket or a malicious one.
>
>> separate management and forwarding interfaces on a router, don't
>> practically solve this problem.
>
> I don't think this is practiable, especially in times of small devices
> doing routing (e.g. smartphones).
>
>> I'd also be curious to hear what
>> dedicated routing operating systems do, and why I haven't heard about
>> widespread fragmentation DoS attacks.
>
> My old Cisco didn't honour those pmtu packets (at least in default
> configuration) and FreeBSD only accepts pmtu information for TCP sockets
> where it also verifies the sequence number. It does not react to pmtu
> notifications in response to icmp or udp payloads.
>
> Routing path does use the pmtu values on FreeBSD, though. But it is much
> harder to inject path mtu packets there because, as said, they are only
> accepted for tcp.

Would it be sufficient to allow Linux to be configured in a way that
matches FreeBSD's behavior?  (I believe you can do this easily with
stateful firewall rules now, or possibly in the ICMP processing code
with a sysctl switch.)  I feel this would be a much cleaner approach.

Thanks,
  -John
