From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Thu, 9 Jan 2014 17:09:11 -0800
Message-ID: <CAM_iQpUL6TAmfyC4kruNB5p9+Qh+sPtUbRC3xPDsLp2g=yxC_A@mail.gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com>
	<1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpUj9kg=15K3yyOWuMEaxWQC2TUStAMjHrn+ixbGyYHK0Q@mail.gmail.com>
	<20140109164936.4b17cf38@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:58556 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaAJBJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 20:09:12 -0500
Received: by mail-oa0-f46.google.com with SMTP id l6so4329408oag.33
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 17:09:12 -0800 (PST)
In-Reply-To: <20140109164936.4b17cf38@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 4:49 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> I think what Eric is saying is that on a multi-queue NIC, multiple
> queues can be receiving packets and then sending them on to the ingress
> queue discipline. Up until your patch that code itself was protected
> by qdisc_lock and did not have to worry about any SMP issues. Now, any
> qdisc attached on ingress could run in parallel. This would break all
> the code in those queue disciplines. Think of the simplest case
> of policing.

I noticed that we have multiqueue for rx, which is dev->_rx[], so they
still share the name dev->ingress_queue. Packets on different CPU's
from the same device still need to run through the same ingress qdisc.

Except for ifb, ingress qdisc can only do filtering (with some actions),
therefore I still don't see the problem.

ifb device switches to its "egress" to do policing, which is safe since it
does not use ->ingress_queue any more.
