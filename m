From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/6] net: Fix ns_capable check in packet_diag_dump
Date: Tue, 22 Apr 2014 14:15:47 -0700
Message-ID: <87bnvtnjzw.fsf_-_@x220.int.ebiederm.org>
References: <CALCETrUaYhh6Dkzn0TMEUz-GEO9-6ObByk5d_xRViSMBbp5Pkg@mail.gmail.com>
	<cover.1397840611.git.luto@amacapital.net>
	<6daf425e2023266d52d181e4d2ee18747d4f1fa8.1397840611.git.luto@amacapital.net>
	<87tx9nuxf6.fsf@x220.int.ebiederm.org>
	<CALCETrUqNVRBse4rUeUKfgYt0d+9x1JrEHGcZ_DnWyq7W6Yyzw@mail.gmail.com>
	<87r44qtabz.fsf@x220.int.ebiederm.org>
	<CALCETrWzUQ7QjykT85ExDfX-+9eDD-D-dcxofUMPvLK=ia9arg@mail.gmail.com>
	<87r44qrt8v.fsf_-_@x220.int.ebiederm.org>
	<87r44pnk3c.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vivek Goyal <vgoyal@redhat.com>, Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:53033 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756744AbaDVVQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 17:16:17 -0400
In-Reply-To: <87r44pnk3c.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 22 Apr 2014 14:13:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The caller needs capabilities on the namespace being queried, not on
their own namespace.  This is a security bug, although it likely has
only a minor impact.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/packet/diag.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/packet/diag.c b/net/packet/diag.c
index f5ad130ee3b8..b34d0de24091 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -194,8 +194,7 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	net = sock_net(skb->sk);
 	req = nlmsg_data(cb->nlh);
-	may_report_filterinfo =
-		ns_capable(sk_user_ns(NETLINK_CB(cb->skb).sk), CAP_NET_ADMIN);
+	may_report_filterinfo = ns_capable(net->user_ns, CAP_NET_ADMIN);
 
 	mutex_lock(&net->packet.sklist_lock);
 	sk_for_each(sk, &net->packet.sklist) {
-- 
1.9.1
