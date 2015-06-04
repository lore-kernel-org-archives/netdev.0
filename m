From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [RFC PATCH net-next] tcp: add CDG congestion control
Date: Thu, 4 Jun 2015 17:41:03 +0200
Message-ID: <CA++eYdtEpbvJFroDCJ1uduj2EQvH1XkkmRmPkuOaQf2mMe099g@mail.gmail.com>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
	<1431913614.621.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	netdev <netdev@vger.kernel.org>,
	David Hayes <davihay@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34010 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbbFDPlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:41:05 -0400
Received: by wibut5 with SMTP id ut5so25657391wib.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:41:03 -0700 (PDT)
In-Reply-To: <1431913614.621.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +static  int window __read_mostly = 8;
>
> This is a (readonly) module parameter, but really is a constant (if you
> ever try to change it dynamically, bad things will happen in current
> code)
>
> const int window = 8;

It cannot be adjusted dynamically, but we can override the initial
window parameter when loading tcp_cdg as a module. Imho, this is a
good enough interface when considering that tuning CDG's parameters
are for special interest groups in the first place.

window, backoff_factor and backoff_beta are the most important knobs
that influence CDG's backoff behavior. We could remove window as a
parameter (make it constant), although that would make tuning it
rather tedious. We could also make window adjustable dynamically, but
I opt on waiting until someone needs this functionality before adding
the code. Or am I missing something?
