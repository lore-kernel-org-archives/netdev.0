From: "H. Willstrand" <h.willstrand@gmail.com>
Subject: Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Sun, 11 Jan 2009 23:08:16 +0100
Message-ID: <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com>
References: <20090111212303.GA8612@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: bert hubert <bert.hubert@netherlabs.nl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:17068 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbZAKWIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 17:08:19 -0500
Received: by rv-out-0506.google.com with SMTP id k40so9946117rvb.1
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2009 14:08:19 -0800 (PST)
In-Reply-To: <20090111212303.GA8612@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 10:23 PM, bert hubert <bert.hubert@netherlabs.nl> wrote:
> Hi everybody,
>
> I have an application where I need to send data from A to B, and beforehand,
> I don't know how much data this will be.
>
> B is 'stupid', and consists solely of a TCP/IP port accepting data, and I
> have no way to chunk this data. So what I do is issue blocking calls to
> write(), shutdown(fd, SHUT_WR), and wait for the fd to become readable which
> tells me that the remote has packed up, and I'm good to go.
>
> Before this, I've tried SO_LINGER with various timeouts but nothing helped.
>
> When I tcpdump, I find that my close() is immediately turned into an RST
> packet.
>
> Is SO_LINGER a NOOP? Does it still do anything?
>
> I'm about to blog this up - the 'shutdown() and read()' technique is
> something I had to purloin from the Apache source.
>
> So I'd love to know the words of the wise on this one.
>
> Thanks.
>
> --
> http://www.PowerDNS.com      Open source, database driven DNS Software
> http://netherlabs.nl              Open and Closed source services
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

This is the correct behavior according to RFC 2525, see section 2.17
(there are an example).

//H.W.
