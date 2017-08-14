From: Thiago Macieira <thiago.macieira@intel.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Mon, 14 Aug 2017 11:58:30 -0700
Message-ID: <1756525.aGoekHffaC@tjmaciei-mobl1>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1604496.falisOBPe2@tjmaciei-mobl1> <CAF=yD-L_-XrrPTfqYKGShqYdadER_Qo9_0CoAYE0r=NrircDXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47879 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751472AbdHNS6h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 14:58:37 -0400
In-Reply-To: <CAF=yD-L_-XrrPTfqYKGShqYdadER_Qo9_0CoAYE0r=NrircDXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 14 August 2017 11:46:42 PDT Willem de Bruijn wrote:
> > By the way, what were the usecases for the peek offset feature?
> 
> The idea was to be able to peek at application headers of upper
> layer protocols and multiplex messages among threads. It proved
> so complex even for UDP that we did not attempt the same feature
> for TCP. Also, KCM implements demultiplexing using eBPF today.

Interesting, but how would userspace coordinate like that? Suppose multiple 
threads are woken up by a datagram being received, they peek at a certain 
offset shared among them all to see which one reads. Suppose that thread is 
slow or blocked and, while it's getting its act together, another datagram 
arrives.

Because of that, the other threads can't disable their polling. They will 
continually be woken up by the kernel if they go back to poll/select. Even 
with epoll, there's no new edge trigger since event is already at level.

How will they avoid busy-waiting? And won't this secondary coordination 
obviate the need for offset peeking?

-- 
Thiago Macieira - thiago.macieira (AT) intel.com
  Software Architect - Intel Open Source Technology Center
