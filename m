From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 8/9] bpf: sockmap requires STREAM_PARSER add
 Kconfig entry
Date: Mon, 28 Aug 2017 07:12:21 -0700
Message-ID: <20170828141221.14143.27371.stgit@john-Precision-Tower-5810>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35716 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751170AbdH1OMg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:12:36 -0400
Received: by mail-pg0-f65.google.com with SMTP id r133so462369pgr.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:12:36 -0700 (PDT)
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SOCKMAP uses strparser code (compiled with Kconfig option
CONFIG_STREAM_PARSER) to run the parser BPF program. Without this
config option set sockmap wont be compiled. However, at the moment
the only way to pull in the strparser code is to enable KCM.

To resolve this create a BPF specific config option to pull
only the strparser piece in that sockmap needs. This also
allows folks who want to use BPF/syscall/maps but don't need
sockmap to easily opt out.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 net/Kconfig |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/Kconfig b/net/Kconfig
index 7d57ef3..17ca213 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -301,6 +301,18 @@ config BPF_JIT
 	  /proc/sys/net/core/bpf_jit_harden   (optional)
 	  /proc/sys/net/core/bpf_jit_kallsyms (optional)
 
+config BPF_STREAM_PARSER
+	bool "enable BPF STREAM_PARSER"
+	depends on BPF_SYSCALL
+	select STREAM_PARSER
+	---help---
+	 Enabling this allows a stream parser to be used with
+	 BPF_MAP_TYPE_SOCKMAP.
+
+	 BPF_MAP_TYPE_SOCKMAP provides a map type to use with network sockets.
+	 It can be used to enforce socket policy, implement socket redirects,
+	 etc.
+
 config NET_FLOW_LIMIT
 	bool
 	depends on RPS
