From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 16:37:38 -0500
Message-ID: <20170228213738.GB28302@oracle.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
 <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228210623.GA28302@oracle.com>
 <CACT4Y+akanLaOw6M0=Q8kzrD9TTDUw1_J7kj-S7zUVgT_zMW+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: syzkaller <syzkaller@googlegroups.com>,
        netdev <netdev@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:22819 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdB1WbO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 17:31:14 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v1SLcjgF006704
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 21:38:45 GMT
Content-Disposition: inline
In-Reply-To: <CACT4Y+akanLaOw6M0=Q8kzrD9TTDUw1_J7kj-S7zUVgT_zMW+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/01/17 00:14), Dmitry Vyukov wrote:
> 
> But the other 2 use-after-frees happened on cp->cp_send_w. Shouldn't
> we cancel it as well? And cp_recv_w?

yes, good point, I missed that. let me see if I can refactor the code
to release the netns as the last thing before free.. 
