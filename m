From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 04:49:16 -0700
Message-ID: <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Klavs Klavsen <kl@vsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35703 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdGZLtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 07:49:21 -0400
Received: by mail-wm0-f47.google.com with SMTP id c184so76205310wmd.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 04:49:20 -0700 (PDT)
In-Reply-To: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-07-26 at 13:07 +0200, Klavs Klavsen wrote:
> Hi guys,
> 
> Me and my colleagues have an annoying issue with our Linux desktops and 
> the company's Junos VPN.
> 
> We connect with openconnect (some use the official Pulse client) - which 
> then opens up a tun0 device - and traffic runs through that.
> 
> If we try to scp a file of ~100MB (f.ex. linux-4.12.3.tar.xz :) - it 
> stalls after sending 20-30% typicly.. then starts again after some time, 
> and typicly dies before finishing. I've captured it with tcpdump (its a 
> large 77Mb file - thats how far it got before it died :) - 
> http://blog.klavsen.info/fast-retransmit-problem-junos-linux
> 
> I've attached an image of wireshark - where the (AFAIK) interesting part 
> starts.. Where my client starts getting DUP ACK's.. but my Linux client 
> does nothing :(
> I've tried to upgrade to latest Ubuntu-mainline kernel build (4.12.3) 
> and it changed nothing.
> 
> The problem goes away, if I do:
> sysctl -w net.ipv4.tcp_sack=0
> 
> I've tried specificly enabling net.ipv4.tcp_fack=1 - but that did not 
> help.
> 
> This is not an issue on Mac OSX or Windows clients.
> 
> None of the Linux users here figured, that could be a Linux kernel issue 
> - but the evidence seems to suggest it - and all my googleing and 
> reading does not lead me to any other conclusion.
> 
> It may ofcourse be that Junos has implemented the standard badly/wrongly 
> - and Windows/Mac has done a workaround for that?
> 
> I hope you can help me figure out whats going wrong.
> 

sack blocks returned by the remote peer are completely bogus.

Maybe a firewall is messing with them ?

I suspect ACK packets might be simply dropped because of invalid SACK
information.
