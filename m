From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question] net/mlx4_en: Memory consumption issue with mlx4_en
 driver
Date: Thu, 12 Mar 2015 10:24:01 -0700
Message-ID: <1426181041.11398.164.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150311185146.GA1032293@devbig242.prn2.facebook.com>
	 <1426105262.11398.66.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150312165647.GD1032293@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	kernel-team@fb.com
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33123 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbbCLRYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 13:24:08 -0400
Received: by iecvj10 with SMTP id vj10so48593557iec.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 10:24:07 -0700 (PDT)
In-Reply-To: <20150312165647.GD1032293@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-12 at 09:56 -0700, Martin Lau wrote:

> It is what we did.  However, a buggy process accommodated enough stalled
> sockets (stop reading from it but not closing it) will re-surface the problem.

That's where collapsing helps : TCP stack reallocates linear skbs using
order-0 pages only, and fill them. Overhead is reduced to strict
minimum.

Well, this collapsing code could be extended to add order-0 pages frags,
so that overhead would be really minimal.

I'll send patches that we have been using here for a while.
