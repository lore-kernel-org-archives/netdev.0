From: David Miller <davem@davemloft.net>
Subject: Re: [regression v4.11] 617f01211baf ("8139too: use
 napi_complete_done()")
Date: Fri, 07 Apr 2017 11:42:16 -0700 (PDT)
Message-ID: <20170407.114216.29873489271414092.davem@davemloft.net>
References: <20170407181754.GL30290@intel.com>
        <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ville.syrjala@linux.intel.com, edumazet@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58900 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754895AbdDGSmW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:42:22 -0400
In-Reply-To: <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Apr 2017 11:38:49 -0700

> I do not really see what could be wrong, the code should run just fine
> on UP.

One theory is that the interrupt masking isn't working properly
and interrupts are still arriving and hitting the NAPI state even
when we are actively polling NAPI.

And this problem was masked by the locking done here.
