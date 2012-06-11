From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH] net: Reorder initialization in ip_route_output to fix gcc warning
Date: Mon, 11 Jun 2012 00:00:51 -0700
Message-ID: <CAG4TOxNpw0BAWPK3Zde_mThTvY-ho+Ce_aau3DoLc-0TRFq3PQ@mail.gmail.com>
References: <1339394724-28296-1-git-send-email-roland@kernel.org> <20120610.234411.850948486629299757.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52893 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab2FKHBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 03:01:13 -0400
Received: by wgbdr13 with SMTP id dr13so2890549wgb.1
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 00:01:12 -0700 (PDT)
In-Reply-To: <20120610.234411.850948486629299757.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I can't figure out what it is actually warning about, can you?

I think gcc thinks it already initialized the __fl_common struct
once when it hits the .flowi4_oif initializer (which expands to
__fl_common.flowic_oif), and then having the .daddr / .saddr
initializers makes it thinks its done with that structure.

So it thinks it's initializing __fl_common.flowic_tos to 0, and
then the .flowi4_tos initializer comes along as a surprise.

Hmm, looks like http://gcc.gnu.org/bugzilla/show_bug.cgi?id=52880
which is fixed after gcc 4.7.0.  I think it's probably worth working
around this gcc issue, since this makes W=1 way noisier in
my build.

 - R.
