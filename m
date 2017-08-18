From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] bpf: fix a return in sockmap_get_from_fd()
Date: Fri, 18 Aug 2017 10:27:02 +0300
Message-ID: <20170818071210.wyq37kura6wz6bx6@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47832 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdHRH1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 03:27:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"map" is a valid pointer.  We wanted to return "err" instead.  Also
let's return a zero literal at the end.

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d2f2bdf71ffa..b8cb1b3c9bfb 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1125,11 +1125,11 @@ static int sockmap_get_from_fd(const union bpf_attr *attr, int ptype)
 		fdput(f);
 		bpf_prog_put(prog1);
 		bpf_prog_put(prog2);
-		return PTR_ERR(map);
+		return err;
 	}
 
 	fdput(f);
-	return err;
+	return 0;
 }
 
 static int bpf_prog_attach(const union bpf_attr *attr)
