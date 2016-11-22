From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] flow_dissect: call init_default_flow_dissectors()
 earlier
Date: Tue, 22 Nov 2016 11:17:30 -0800
Message-ID: <1479842250.8455.452.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161121092855.GA20976@kroah.com>
         <20161122165912.GA19939@tuebingen.mpg.de>
         <20161122170654.GA20022@kroah.com>
         <CANn89iJCkHxOpE3TW8+gW8+UCVvT0mY8y8j_GJC1GK0i05dgbg@mail.gmail.com>
         <1479836511.681.165.camel@intel.com>
         <CANn89iLdtfoYDVoszduyKCpmZpYcpV2=UnwbjAzH0G08nzNwbw@mail.gmail.com>
         <20161122175504.GD19939@tuebingen.mpg.de>
         <CANn89iKZMcnzLJUNE286pBKSaL3kcrBgwpdihxSMm8Ze5L_-qw@mail.gmail.com>
         <20161122180605.GE19939@tuebingen.mpg.de>
         <1479838123.681.173.camel@intel.com>
         <20161122182258.GF19939@tuebingen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ast@kernel.org" <ast@kernel.org>,
        "willemb@google.com" <willemb@google.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "jslaby@suse.cz" <jslaby@suse.cz>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "yibyang@cisco.com" <yibyang@cisco.com>,
        netdev <netdev@vger.kernel.org>
To: Andre Noll <maan@tuebingen.mpg.de>, Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161122182258.GF19939@tuebingen.mpg.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Andre Noll reported panics after my recent fix (commit 34fad54c2537
"net: __skb_flow_dissect() must cap its return value")

After some more headaches, Alexander root caused the problem to
init_default_flow_dissectors() being called too late, in case
a network driver like IGB is not a module and receives DHCP message
very early.

Fix is to call init_default_flow_dissectors() much earlier,
as it is a core infrastructure and does not depend on another
kernel service.

Fixes: 06635a35d13d4 ("flow_dissect: use programable dissector in skb_flow_dissect and friends")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andre Noll <maan@tuebingen.mpg.de>
Diagnosed-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/flow_dissector.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 69e4463a4b1b..c6d8207ffa7e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -1013,4 +1013,4 @@ static int __init init_default_flow_dissectors(void)
 	return 0;
 }
 
-late_initcall_sync(init_default_flow_dissectors);
+core_initcall(init_default_flow_dissectors);
