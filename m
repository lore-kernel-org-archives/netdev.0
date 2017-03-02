From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dccp: Unlock sock before calling sk_free()
Date: Thu, 02 Mar 2017 13:59:20 -0800 (PST)
Message-ID: <20170302.135920.357751469126889997.davem@davemloft.net>
References: <20170301193508.25760-1-acme@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, gerrit@erg.abdn.ac.uk, tglx@linutronix.de
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdCBWJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 17:09:16 -0500
In-Reply-To: <20170301193508.25760-1-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Wed,  1 Mar 2017 16:35:07 -0300

> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> The code where sk_clone() came from created a new socket and locked it,
> but then, on the error path didn't unlock it.
> 
> This problem stayed there for a long while, till b0691c8ee7c2 ("net:
> Unlock sock before calling sk_free()") fixed it, but unfortunately the
> callers of sk_clone() (now sk_clone_locked()) were not audited and the
> one in dccp_create_openreq_child() remained.
> 
> Now in the age of the syskaller fuzzer, this was finally uncovered, as
> reported by Dmitry:
 ...
> Fix it just like was done by b0691c8ee7c2 ("net: Unlock sock before calling
> sk_free()").
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Link: http://lkml.kernel.org/r/20170301153510.GE15145@kernel.org
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied and queued up for -stable.
