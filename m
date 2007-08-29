From: "Grant Grundler" <grundler@google.com>
Subject: Re: pktgen terminating condition
Date: Wed, 29 Aug 2007 09:26:18 -0700
Message-ID: <da824cf30708290926n4847a86bj368fe27f69145147@mail.gmail.com>
References: <1188347327.4305.27.camel@localhost>
	 <20070829044352.GA4133@ludhiana>
	 <20070828.220402.15268351.davem@davemloft.net>
	 <535ddc6b0708290914k21d0b71fs21ea3b96c6fd7f4d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, hadi@cyberus.ca,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	robert.olsson@its.uu.se, venza@brownhat.org
To: "Mandeep Baines" <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:6926 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbXH2Q0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 12:26:35 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id l7TGQNj4002366
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 17:26:23 +0100
Received: from py-out-1112.google.com (pybp76.prod.google.com [10.34.92.76])
	by zps18.corp.google.com with ESMTP id l7TGPBve020630
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 09:26:19 -0700
Received: by py-out-1112.google.com with SMTP id p76so2328945pyb
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 09:26:19 -0700 (PDT)
In-Reply-To: <535ddc6b0708290914k21d0b71fs21ea3b96c6fd7f4d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/29/07, Mandeep Baines <mandeep.baines@gmail.com> wrote:
...
> Unfortunately, the TxIdle interrupt would not free the last odd packet.
> However, if we want to quiet interrupts couldn't the driver just be
> converted NAPI. If this seems reasonable I could work on a patch.

It seems reasonable and that's what I was thinking when you
submitted the patch to use TXOk.

I think NAPI could be used with either TxOK or TxIdle interrupts.
For TxIdle to work, the driver would have to recognize one more
packet is still in flight and poll for completion of that packet - then
re-enable interrupts and switch back to interrupt mode of operation.
I just don't know if netperf TCP_RR perf numbers will suffer
(assuming TCP_RR is more important than CPU utilization/efficiency
on heavy TX loads like pktgen.)

grant
