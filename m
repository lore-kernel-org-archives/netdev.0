From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC v2 net-next] rds-tcp: Take explicit refcounts on
 struct net
Date: Thu, 2 Mar 2017 05:46:33 -0500
Message-ID: <20170302104633.GD23804@oracle.com>
References: <1488299601-162004-1-git-send-email-sowmini.varadhan@oracle.com>
 <CACT4Y+Zzqq38Av-brhoDYpyY_1cvxTGjxehZkzz9wwF3GjcTdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:49044 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdCBKtJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 05:49:09 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v22AmXpd031606
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 2 Mar 2017 10:48:33 GMT
Content-Disposition: inline
In-Reply-To: <CACT4Y+Zzqq38Av-brhoDYpyY_1cvxTGjxehZkzz9wwF3GjcTdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/02/17 11:07), Dmitry Vyukov wrote:
> 
> The other 2 does not look like net-related, but you also mailed patch
> "Cancel any pending connection attempts before taking down
> connection", which looks like it should fix the other 2, right?

no, that patch was still broken.. because, as you pointed out,
it only takes care of one workq, and not the other workqs. Also,
there are a number of clean up operations performed on the socket
associated with the rds_connection, all of which could potentially
be in jeopardy if the race is happening as suspected. I think the
v2 patch (this subject line) is the more appropriate fix- I see
that same thing is being done for svc_xprt's xpt_net, for example.

> I now applied both of your patched on bots. But only happened 1+2
> times over the last 2 weeks. So it will require at least a month to
> make a weak conclusion that it might have helped. So I would suggest
> to either (1) re-review the crash reports, the code and the fix and
> commit it if everything looks consistent, or (2) write a stress test
> that provokes the bugs as much as possible, add some sleeps into the
> kernel code, reproduce the crashes and check that the patches fix
> them.

I can try both, but IME reproducing such things is quite challenging.
Even with things like dtrace-chill on other OSes, it can take a loong
time to nail it. Let's give it a week, while I try out (1) at least.

--Sowmini
