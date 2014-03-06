From: John Heffner <johnwheffner@gmail.com>
Subject: Re: Can I limit the number of active tx per TCP socket?
Date: Thu, 6 Mar 2014 09:15:37 -0500
Message-ID: <CABrhC0kpuuHFxgr8BsJA3rTcoo49mb6nOYcuomwsRMPq=p1wQA@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:40201 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbaCFOPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 09:15:38 -0500
Received: by mail-vc0-f177.google.com with SMTP id if11so2559238vcb.8
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 06:15:37 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is TCP_CORK what you're looking for?


On Thu, Mar 6, 2014 at 7:28 AM, David Laight <David.Laight@aculab.com> wrote:
> Is it possible to stop a TCP connection having more than one
> tx skb (in the ethernet tx ring) at any one time?
> The idea is to allow time for short sends from the application
> to accumulate so that the transmitted frames are longer.
>
> Basically I have a TCP connection which carries a lot of separate
> short 'user buffers'. These are not command-response so
> TCP_NODELAY has to be set to avoid long delays. But this means
> that the ethernet packet rate is very high - with 3.14 about
> 2000/sec even though the data rate is well under 1MB/sec.
>
> Anything that reduces this packet rate will help the poor little
> embedded ppc that has to receive them!
>
> From the descriptions I've found I suspect that setting a very
> low TCP_NOTSENT_LOWAT (like 1 byte) might have other side effects.
> I think that limits the writes into kernel memory - which isn't
> really what I'm trying to do.
>
> With a 3.14.0-rc5 kernel reducing the network speed to 10M (from Ge)
> halves the number of transmitted packets (with the same aggregate
> data rate). But I suspect it could still be reduced further.
>
> Limiting the number of tx packets per TCP connection might also
> help stop bulk transfers affecting low-latency connections,
> especially if the throughput of individual connections isn't
> especially important - as it may not be on a big ftp/web server.
>
> Limiting the window size offered by the remote system won't help me.
> The window needs to be large enough several full-sized packets, and
> I'm trying to stop large numbers of very short packets being sent.
>
> In this particular case the connection is local, but we have a similar
> problem with sigtran m3ua traffic over sctp.
> If we are sending 15000 sctp data chunks every second, with an average size
> under 300 bytes (possibly nearer 150) then we really want to fill the
> ethernet packets.
> (That is a real data pattern, not a development test.)
>
>         David
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
