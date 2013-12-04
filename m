From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAPI rescheduling and the delay caused by it
Date: Wed, 04 Dec 2013 12:41:58 -0800
Message-ID: <1386189718.30495.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <529F7A87.5080303@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:39650 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933010Ab3LDUmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 15:42:02 -0500
Received: by mail-yh0-f41.google.com with SMTP id f11so11838194yha.14
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 12:42:01 -0800 (PST)
In-Reply-To: <529F7A87.5080303@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-04 at 18:55 +0000, Zoltan Kiss wrote:

> So, my questions are:
> - why is NAPI rescheduled on an another CPU?
> - why does it cause a 3-4 milisec delay?

NAPI can not be scheduled on another cpu.

But at the time of napi_schedule() call, napi_struct can be already be
scheduled by another cpu.

( NAPI_STATE_SCHED bit already set)

So I would say something made the 'other' cpu non responsive fast enough
to softirq events being ready for service.

(Another wakeup happened 3-4 millisec later)

Really, I suspect your usage of netif_wake_queue() is simply wrong.

Check why we have netif_rx() and netif_rx_ni() variants.

And ask yourself if xenvif_notify_tx_completion() is correct, being
called from process context.
