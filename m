From: Nir Tzachar <nir.tzachar@gmail.com>
Subject: Re: [RFCv4 PATCH 2/2] net: Allow protocols to provide an
	unlocked_recvmsg socket method
Date: Thu, 1 Oct 2009 11:49:39 +0200
Message-ID: <9b2db90b0910010249h182bf5d4sc7fdaea9e1345720@mail.gmail.com>
References: <20090916170745.GD7699@ghostprotocols.net>
	 <9b2db90b0909170709n400859c6q13514b315970dde9@mail.gmail.com>
	 <20090917212113.GC3691@ghostprotocols.net>
	 <20090917215344.GE3691@ghostprotocols.net>
	 <20090923000925.GA6011@ghostprotocols.net>
	 <9b2db90b0909222123x7e547210p5755adf9f8ae875f@mail.gmail.com>
	 <20090923043813.GA6464@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ziv Ayalon <ziv@final.co.il>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:52929 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050AbZJAJtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 05:49:36 -0400
Received: by fxm18 with SMTP id 18so6035209fxm.17
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2009 02:49:40 -0700 (PDT)
In-Reply-To: <20090923043813.GA6464@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaldo

I have repeated the tests using net-next on top of linus' git tree (I
hope I got it right..) and the patches you sent me. Things did not get
better, and in most cases were even worse; the recvmmsg parts
distinctly showed better throughput, but the latency has more than
doubled.

The simplest test of using a batch size of 1 results with recvmmsg's
latency over 1000 micro, while regular recvmsg is around 450 micro.
(note that to use 1 packet there is a small bug in the reg_recv which
needs to be fixed. Namely, change ret = -1 to ret = 0). On the
previous system config -- part 0001 of the patch, on top of 2.6.31 --
the latency of a single packet batch is 370 micro.

So, there seems to be a regression with the kernel tree I am using, or
with part 0002 of the path. I'll try running the net-next with only
part 1 of the patch and report.

Cheers.
