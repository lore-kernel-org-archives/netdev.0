From: Richard Weinberger <richard@nod.at>
Subject: nf_conntrack: Infoleak via CTA_ID and CTA_EXPECT_ID
Date: Fri, 30 Jun 2017 21:25:15 +0200
Message-ID: <c84e0301-2bb6-8932-2ed5-939340762159@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, fw@strlen.de,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Gstir <david@sigma-star.at>, kaber@trash.net,
        "keescook@chromium.org" <keescook@chromium.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I noticed that nf_conntrack leaks kernel addresses, it uses the memory address
as identifier used for generating conntrack and expect ids..
Since these ids are also visible to unprivileged users via network namespaces
I suggest reverting these commits:

commit 7f85f914721ffcef382a57995182916bd43d8a65
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 28 14:41:27 2007 -0700

    [NETFILTER]: nf_conntrack: kill unique ID

    Remove the per-conntrack ID, its not necessary anymore for dumping.
    For compatiblity reasons we send the address of the conntrack to
    userspace as ID.

    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 3583240249ef354760e04ae49bd7b462a638f40c
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 28 14:41:50 2007 -0700

    [NETFILTER]: nf_conntrack_expect: kill unique ID

    Similar to the conntrack ID, the per-expectation ID is not needed
    anymore, kill it.

    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks,
//richard
