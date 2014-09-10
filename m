From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rtt vs. rcv_rtt ?
Date: Wed, 10 Sep 2014 11:06:46 -0700
Message-ID: <1410372406.7106.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+q+rD1=ohtL5EkoXkSVS5A5ygop4ev3CoN=HOLNSrTPp7BtiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Engels <rengels@optionscity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:38343 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbaIJSGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 14:06:48 -0400
Received: by mail-pa0-f49.google.com with SMTP id lf10so6170721pab.8
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 11:06:48 -0700 (PDT)
In-Reply-To: <CA+q+rD1=ohtL5EkoXkSVS5A5ygop4ev3CoN=HOLNSrTPp7BtiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 12:15 -0500, Robert Engels wrote:
> When using 'ss', both rtt, and rcv_rtt are reported.
> 
> My understanding is that rcv_rtt is an estimate of the receivers rtt ?? Is
> this true? My assumption is that differences in rtt vs. rcv_rtt would be
> due to asymmetric networking connections ???
> 
> Here is a sample 'ss' output:
> 
>  cubic wscale:2,9 rto:437 rtt:101.625/84 ato:40 cwnd:10 ssthresh:15 send
> 991.9Kbps rcv_rtt:18291 rcv_space:151142
> 
> Can someone explain why the rcv_rtt would be so much higher than the rtt?
> Is it that the client is not reading the data fast enough? Other reasons?
> 
> Thanks so much for your help.

rcv_rtt is not the rtt as you think it is ;)

rtt is the smooth rtt of delays between sent packets and received ACK.

But rcv_rtt is the time to receive one full window.

Its used by DRS (Dynamic Right-Sizing) 
Check tcp_rcv_rtt_measure() & tcp_rcv_rtt_update() for details.
