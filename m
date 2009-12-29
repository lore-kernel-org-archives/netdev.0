From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange TCP behavior over HSDPA
Date: Tue, 29 Dec 2009 19:31:13 +0100
Message-ID: <20091229183113.GA3081@del.dom.local>
References: <20091229083050.GA7209@ff.dom.local>
 <4B39D30F.8090006@gmail.com>
 <20091229105748.GB7209@ff.dom.local>
 <20091229121624.GC7209@ff.dom.local>
 <20091229133620.GA9552@ff.dom.local>
 <4B3A1284.2030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:46953 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbZL2SbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 13:31:21 -0500
Received: by fxm25 with SMTP id 25so5451572fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 10:31:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B3A1284.2030101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 03:30:28PM +0100, Kristian Evensen wrote:
> Den 29.12.2009 14:36, skrev Jarek Poplawski:
> >On Tue, Dec 29, 2009 at 12:16:24PM +0000, Jarek Poplawski wrote:
> >>On Tue, Dec 29, 2009 at 10:57:48AM +0000, Jarek Poplawski wrote:
> >>>Did you try to turn off TCP window scaling btw? Anyway, under the
> >>>tunnel ([2]), when SACK worked, it saved you a lot of retransmits.
> >>Hmm... Actually, after re-checking, there weren't much more of those
> >>retransmits at all. In [1] there was one more packet lost, so it took
> >>a bit longer. In [2] (with SACK) the retransmit started earlier and
> >>the rcv window was unchanged. So, it rather looks like differences
> >>in timing of TCP recovery techniques.
> >Hmm#2... On the other hand, I can imagine cases with a larger data
> >loss, where working SACK should really save on retransmits.
> >
> >Jarek P.
> Thanks for all your comments. I have not tried to disable window
> scaling, but will try that as soon as possible. I also noticed the
> second packet loss in [1], but I don't think it affected the
> situation to much. In similar packet captures, the transfer without
> the tunnel has only lost one packet and the throughput drop has been
> just as significant as in [1]. It rather seems to be, as you point
> out, differences in timing of the recovery techniques, probably
> between this accelerator and the server.

Then disabling window scaling seems too radical; maybe you should try
with lower tcp_rmem max etc.

> 
> However, I find it a bit strange the dupAcks are sent back to the
> server. Based on my, I must admit limited, knowledge of
> accelerators, they will buffer and ACK packets if they for example
> are responsible for retransmissions. But again, maybe it uses the
> dupAcks to tell the server to slow down and then simply discards the
> retransmitted packet.

I'm not a TCP expert, but IMHO you don't need much knowledge to assess
quality of this accelerator, if you get better results when omitting
it (partly) with a tunnel ;-)

Jarek P.
