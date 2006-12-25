From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Mon, 25 Dec 2006 14:54:45 +0200
Message-ID: <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:63891 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbWLYMyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Dec 2006 07:54:47 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4469254nfa
        for <netdev@vger.kernel.org>; Mon, 25 Dec 2006 04:54:45 -0800 (PST)
To: "Arjan van de Ven" <arjan@infradead.org>
In-Reply-To: <1167046499.3281.1623.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan,

On 12/25/06, Arjan van de Ven <arjan@infradead.org> wrote:
> On Mon, 2006-12-25 at 13:26 +0200, Robert Iakobashvili wrote:
> >
> > > Am I understanding you correctly that you want to spread the load of the
> > > networking IRQ roughly equally over 2 cpus (or cores or ..)?
> >
> > Yes, 4 cores.
> >
> > > If so, that is very very suboptimal, especially for networking (since
> > > suddenly a lot of packet processing gets to deal with out of order
> > > receives and cross-cpu reassembly).
> >
> > Agree. Unfortunately, we have a flow of small RTP packets with heavy
> > processing and both Rx and Tx component on a single network card.
> > The application is not too much sensitive to the out of order, etc.
> > Thus, there 3 cores are actually doing nothing, whereas the CPU0
> > is overloaded, preventing system CPU scaling.
>
> in principle the actual work should still be spread over the cores;
> unless you do everything in kernel space that is..

This is the case. The processing is in kernel.

> > Agree, that providing CPU affinity for a network interrupt is a rather
> > reasonable default.
> > However, should a chipset manufacture take from us the very freedom of
> > tuning, freedom of choice?
>
> it can still be done using the TPR (Thread Priority Register) of the
> APIC. It's just... not there in Linux (other OSes do use this).

Interesting.
Have you any specific pointers for doing it (beyond Internet search)?
Your input would be very much appreciated.
Thank you.


-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://sourceforge.net/projects/curl-loader
A powerful open-source HTTP/S, FTP/S traffic
generating, loading and testing tool.
