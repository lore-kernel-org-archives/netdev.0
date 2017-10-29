From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] l2tp: register sessions atomically
Date: Sun, 29 Oct 2017 11:16:39 +0900 (KST)
Message-ID: <20171029.111639.1982562227530012004.davem@davemloft.net>
References: <cover.1509111405.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdJ2CQn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 22:16:43 -0400
In-Reply-To: <cover.1509111405.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 27 Oct 2017 16:51:48 +0200

> Currently l2tp_session_create() allocates a session, partially
> initialises it and finally registers it. It therefore exposes sessions
> that aren't fully initialised to the rest of the system, because
> pseudo-wire specific initialisation can only happen after
> l2tp_session_create() returns.
> This leads to several crashes when these sessions are used or deleted.
> 
> This series starts by splitting session registration out of
> l2tp_session_create() (patch #1). Thus allowing pseudo-wires code to
> terminate the initialisation phase before registration.
> 
> Then patch #2 fixes the eth pseudo-wire code. This requires protecting
> the session's netdevice pointer with RCU, because it still needs to be
> updated concurrently after the session got registered.
> 
> Remaining patches take care of ppp pseudo-wires. RCU protection is
> needed there too, for the same reasons. This time it's the pppol2tp
> socket pointer that gets protected. For clarity, and since the
> conversion requires more modifications, introducing RCU is done in
> its own patch (#3). Then patch #4 only has to take care of fixing
> sessions initialisation and registration (and adapting part of the
> deletion process).

Series applied, thank you.
