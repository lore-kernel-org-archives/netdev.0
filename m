From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] rhashtable: better high order allocation
 attempts
Date: Fri, 20 Feb 2015 06:58:30 -0800
Message-ID: <1424444310.5565.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1424389682.git.daniel@iogearbox.net>
	 <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
	 <1424439975.5565.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAE688E@AcuExch.aculab.com>
	 <20150220143120.GE4586@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "tgraf@suug.ch" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37613 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbbBTO6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:58:32 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so3579844igq.0
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 06:58:31 -0800 (PST)
In-Reply-To: <20150220143120.GE4586@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-20 at 14:31 +0000, tgraf@suug.ch wrote:

> We can consider switching over to flex arrays at some point
> although NUMA considerations seem much more important to me
> at this point.

flex arrays add a performance cost, much higher than TLB misses of
vmalloc()

I mentioned in the past that vmalloc() could be using hugepages
eventually, so even this TLB cost could be lowered if wanted.
