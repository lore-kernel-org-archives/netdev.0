From: <steven.la@riverbed.com>
Subject: [git][98ed5bb] rvbd/rbt-kernel : master
Date: Thu, 20 Jul 2017 22:22:16 +0000
Message-ID: <20170720222216.24972.34210@leafminer.lab.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Michael@vger.kernel.org, <konrad.wilk@oracle.com>,
        Chan@vger.kernel.org, <mchan@broadcom.com>,
        akepner@vger.kernel.org, Rzeszutek@vger.kernel.org,
        Konrad@vger.kernel.org, Wilk@vger.kernel.org,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.riverbed.com ([208.70.196.45]:7176 "EHLO smtp1.riverbed.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934851AbdGTWWS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Jul 2017 18:22:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


@new_changed_in [{"codename": "banks", "train": "vsfed_merge_sh_mainline", "build_number": 2, "branch": "master"}, {"codename": "aether", "train": "mainline", "build_number": 146, "branch": "master"}, {"codename": "lassen", "train": "mainline", "build_number": 110, "branch": "master"}, {"codename": "milos", "train": "mainline", "build_number": 40, "branch": "master"}, {"codename": "banks", "train": "mainline", "build_number": 133, "branch": "master"}, {"codename": "phantom", "train": "mainline", "build_number": 67, "branch": "master"}]


Repository: git@gitlab.lab.nbttech.com:rvbd/rbt-kernel.git
Branch: master
Author: Steven La <steven.la@riverbed.com>
Date: 2017-07-18T16:34:31-07:00
New Revision: 98ed5bbc446dca588ab8a1a6edbfc870dc9d6933


Log:
Apply the following patches from upstream and port extra skbuff
operating routines used the these patches.

    commit b7b6a688d217936459ff5cf1087b2361db952509
    Author: Ian Campbell <Ian.Campbell@citrix.com>
    Date:   Wed Aug 24 22:28:12 2011 +0000

        bnx2: convert to SKB paged frag API.

        Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
        Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
        Cc: Michael Chan <mchan@broadcom.com>
        Cc: netdev@vger.kernel.org
        Signed-off-by: David S. Miller <davem@davemloft.net>

    commit a1f4e8bcbccf50cf1894c263af4d677d4f566533
    Author: Eric Dumazet <eric.dumazet@gmail.com>
    Date:   Thu Oct 13 07:50:19 2011 +0000

        bnx2: fix skb truesize underestimation

        bnx2 allocates a full page per fragment. We must account PAGE_SIZE
        increments on skb->truesize, not the actual frag length.

        Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>

    commit 9e903e085262ffbf1fc44a17ac06058aca03524a
    Author: Eric Dumazet <eric.dumazet@gmail.com>
    Date:   Tue Oct 18 21:00:24 2011 +0000

        net: add skb frag size accessors

        To ease skb->truesize sanitization, its better to be able to localize
        all references to skb frags size.

        Define accessors : skb_frag_size() to fetch frag size, and
        skb_frag_size_{set|add|sub}() to manipulate it.

        Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
        Signed-off-by: David S. Miller <davem@davemloft.net>

Root Issue Details:
For bug285465, there are some issues for handling paged data.

Fix Summary Details:
Apply the above three patches taken from upstream's code. Since RiOS is
Redhat 6.1 release base, these patches need additionally skbuff helper
routines, porting those as well.

Testing:
Run stress test on the interface that uses this driver.

Fix Complete: # Yes
Risk of Fix: # Low

BugID: 285465
DesignID:
ReviewID:
CC:
Reviewed-By: akepner
Approved-By:


Open this commit in your browser:
https://gitlab.lab.nbttech.com/rvbd/rbt-kernel/commit/98ed5bbc446dca588ab8a1a6edbfc870dc9d6933
