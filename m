From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: [PATCH 1/1] cls_cgroup: Fix oops when user send improperly 'tc
 filter add' request
Date: Tue, 9 Jun 2009 08:54:08 +0900
Message-ID: <20090609085408.9b38ffe1.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, hadi@cyberus.ca, jarkao2@gmail.com
To: containers@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:61330 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbZFIAKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 20:10:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cls_cgroup: Fix oops when user send improperly 'tc filter add' request

I found a bug in cls_cgroup_change() in cls_cgroup.c.
cls_cgroup_change() expected tca[TCA_OPTIONS] was set from user space properly,
but tc in iproute2-2.6.29-1 (which I used) didn't set it.

In the current source code of tc in git, it set tca[TCA_OPTIONS].

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

If we always use a newest iproute2 in git when we use cls_cgroup, 
we don't face this oops probably.
But I think, kernel shouldn't panic regardless of use program's behaviour. 


Signed-off-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index cc29b44..2ec0adc 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -167,6 +167,9 @@ static int cls_cgroup_change(struct tcf_proto *tp, unsigned long base,
 	struct tcf_exts e;
 	int err;
 
+	if (!tca[TCA_OPTIONS])
+		return -EINVAL;
+
 	if (head == NULL) {
 		if (!handle)
 			return -EINVAL;

-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
