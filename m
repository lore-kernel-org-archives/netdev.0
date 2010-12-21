From: "juice" <juice@swagman.org>
Subject: Using ethernet device as efficient small packet generator
Date: Tue, 21 Dec 2010 11:56:42 +0200
Message-ID: <3dbea0c095731ef843058388c29df8c1.squirrel@www.liukuma.net>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:14310 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933556Ab0LUKFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 05:05:44 -0500
Received: from www.liukuma.net (localhost [127.0.0.1])
	by www.liukuma.net (Postfix) with ESMTP id 012571CC67
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 11:56:51 +0200 (EET)
Received: from www.liukuma.net ([127.0.0.1])
	by www.liukuma.net (www.liukuma.net [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id dWYE35HjTeWf for <netdev@vger.kernel.org>;
	Tue, 21 Dec 2010 11:56:42 +0200 (EET)
Received: from www.liukuma.net (localhost [127.0.0.1])
	by www.liukuma.net (Postfix) with ESMTP id A793F1CC60
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 11:56:42 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi net-devvers.

I am involved in telecom equipment R&D, and I need to do some network
performance benchmarking. We need to generate streams of Ethernet/IP/UDP
traffic that consists of different sized payloads ranging from smallest
AMR payload to ethernet MTU.

We have various tools including for example Spirent traffic generators
as well as in-house made software generating 3GPP specified protocol
streams. Now, the problem with the off-the-shelf generators is the
inflexibility in our needs and the unavailability to R&D personnel to
have the generator available at any given time.

For larger packet sizes our linux-based generator is quite sufficent,
as I can use it to fully saturate GE link with packet sizes around 1kB.
However, as packet sizes get smalles ethernet performance suffers.

I did some benchmarking using pktgen with 64B packets against AX4000 and
confirmed that the maximun throughput is only around 25% of GE capacity.
I managed to get to about same speeds using own custom module that writes
skbuffs directly to kernel *xmit of the netdev.

Now, it is evident that something is not optimized to the maximum here
as PCI bus allows for way higher transfer speeds. If large packets can
fully saturate the ethernet link same should apply for minimum sized
packets too, unless there is some overhead I am unaware of.

I have couple of questions here:

1.) Is it possible to enhance the "normal" behaving network driver so
    that the device would still work as an ethernet device (ethxx)?

    Currently the test stream is generated in userland process that
    writes to RAW_SOCK, but it is OK for me if I need to write the
    packet generating part as a kernel module that is configured
    from the userland part to send the prepared stream out.

2.) If it is not possible to get the needed performance from normal
    network architecture, is it possible to make a "generate only"
    ethernet device that I can use to replace the network card driver?

    For example, RX is not really needed at all by my application, so
    just optimizing the driver to send out packets from memory as fast
    as possible is enough.

    Are there notable differences between ethernet chipsets/cards
    regarding to the raw output speed they are capable?
    I have benchmarked e1000, r8169 ang tg3 based cards and with all
    of those I get about same throughput of 64byte ethernet frames.

    For my purpose, it would be OK, for example, to remove the normal
    r8169 driver and replace it with a custom TX-only driver, and use
    some other normal driver tied to another card to access the box.

I appreciate your comments and any pointers to existing projects that
have similar implementation that I require.

Yours, Jussi Ohenoja



