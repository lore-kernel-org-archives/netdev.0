From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 05:20:50 -0800
Message-ID: <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
         <20161116131609.4e5726b4@redhat.com>
         <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
         <20161116234022.2bad179b@redhat.com>
         <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117091638.5fab8494@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36677 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753205AbcKQRO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:14:59 -0500
Received: by mail-pg0-f43.google.com with SMTP id f188so93196692pgc.3
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 09:14:58 -0800 (PST)
In-Reply-To: <20161117091638.5fab8494@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-17 at 09:16 +0100, Jesper Dangaard Brouer wrote:

> 
> I noticed there is a Send-Q, and the perf-top2 is _raw_spin_lock, which
> looks like it comes from __dev_queue_xmit(), but we know from
> experience that this stall is actually caused by writing the
> tailptr/doorbell in the HW.  Thus, this could benefit a lot from
> bulk/xmit_more into the qdisc layer.

The Send-Q is there because of TX-completions being delayed a bit,
because of IRQ mitigation.

(ethtool -c eth0)

It happens even if you do not have a qdisc in the first place.

And we do have xmit_more in the qdisc layer already.
