From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: AW: RFC: replace packets already in queue
Date: Mon, 02 Jul 2012 09:31:50 +0200
Message-ID: <1341214310.5269.27.camel@edumazet-glaptop>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FEC854E.8080603@hp.com>
	 <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
	 <1340960817.15719.6.camel@edumazet-glaptop>
	 <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49194 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594Ab2GBHbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 03:31:53 -0400
Received: by eeit10 with SMTP id t10so1937828eei.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 00:31:52 -0700 (PDT)
In-Reply-To: <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 07:02 +0000, Erdt, Ralph wrote:

> Even if the wireless queue is a problem (because of our setup, this is
> not a problem), the network stack queue (*) is the biggest queue, and
> a good point to optimize. 

Hmm, I am not convinced you have no queues on wireless.

Please describe how you managed this.

In fact this is the biggest problem with wireless : mac82011 framework
aggressively pull packets from Linux packet qdisc in order to perform
packet aggregation.

Most packets don't stay in qdisc but are sitting in wireless driver,
unless you really flood it. If it happens, you already are in trouble.

So code your qdisc thing, but I am not sure you'll get much improvement.
You would need to implement it in wireless code instead.
