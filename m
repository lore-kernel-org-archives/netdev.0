From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Fri, 09 Feb 2007 01:43:44 -0800 (PST)
Message-ID: <20070209.014344.63999119.davem@davemloft.net>
References: <200702091006.24242.dada1@cosmosbay.com>
	<20070209.011542.21927454.davem@davemloft.net>
	<200702091036.58474.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58158
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946270AbXBIJnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 04:43:45 -0500
In-Reply-To: <200702091036.58474.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 9 Feb 2007 10:36:58 +0100

> Thats strange, because pointer arithmetic is unsigned...
> I dont know when gcc started to use reciprocal division, maybe your gcc was 
> very old ?

Yep, it was only on older gcc's.

And as the sparc gcc backend co-maintainer, I remember what the
problem was.  The insn costs for multiply and divide were not set
properly on UltraSPARC, so it used the defaults, which made gcc think
divides were very cheap :-)

Current gcc does the right thing, even for weird sizes like 56 and 52
which expands to many IALU operations.
