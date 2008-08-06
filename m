From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2/m_ipt fix, opts was not set properly
Date: Wed, 06 Aug 2008 06:52:25 -0400
Message-ID: <1218019945.4755.36.camel@localhost>
References: <200808052224.36773.denys@visp.net.lb>
	 <1218016372.4755.15.camel@localhost> <200808061306.39846.denys@visp.net.lb>
	 <1218019350.4755.30.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:27474 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661AbYHFKw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:52:29 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1705511ywe.1
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 03:52:28 -0700 (PDT)
In-Reply-To: <1218019350.4755.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-08 at 06:42 -0400, jamal wrote:

> Sorry Denys, unless my memory has lost the C scoping rules, i dont think
> the shadowing you describe above is accurate. Let me take a closer look.

Grrr. I see the bug; until you tested with batching, it probably hasnt
mattered.
I still dont see how your patch fixes it. But heres a fix that I think
will work:

1. change free_opts to be:

static void free_opts(struct option **opts)
{
        if (*opts != original_opts) {
                free(*opts);
                *opts = original_opts;
        }
}

2. Change invocations of free_opts to be:

free_opts(&opts);

cheers,
jamal

