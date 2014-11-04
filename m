From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] doc ip-cref: Added missing ip options
Date: Tue,  4 Nov 2014 18:54:30 +0200
Message-ID: <1415120070-22662-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:45552 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbaKDRDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:03:48 -0500
Received: by mail-lb0-f182.google.com with SMTP id f15so12787020lbj.27
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:03:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 doc/ip-cref.tex | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index f062b3a..e7a79a5 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -61,6 +61,9 @@ forms. Currently, the following options are available:
 appears twice or more, the amount of information increases.
 As a rule, the information is statistics or some time values.
 
+\item \verb|-d|, \verb|-details|
+
+--- output more detailed information.
 
 \item \verb|-f|, \verb|-family| followed by a protocol family
 identifier: \verb|inet|, \verb|inet6| or \verb|link|.
@@ -103,6 +106,38 @@ host addresses.
  \verb|ip| never uses DNS to resolve names to addresses.
 \end{NB}
 
+\item \verb|-b|, \verb|-batch FILE|
+
+--- read commands from provided file or standart input and invoke them.
+First failure will cause termination of \verb|ip|.
+In batch \verb|FILE| everything which begins with \verb|#| symbol is
+ignored and can be used for comments.
+\paragraph{Example:}
+\begin{verbatim}
+kuznet@kaiser $ cat /tmp/ip_batch.ip
+# This is a comment
+tuntap add mode tap tap1 # This is an another comment
+link set up dev tap1
+addr add 10.0.0.1/24 dev tap1
+kuznet@kaiser $ sudo ip -b /tmp/ip_batch.ip
+\end{verbatim}
+or from standart input:
+\begin{verbatim}
+kuznet@kaiser $ cat /tmp/ip_batch.ip | sudo ip -b -
+\end{verbatim}
+
+\item \verb|-force|
+
+--- don't terminate ip on errors in batch mode.
+If there were any errors during execution of the commands,
+the application return code will be non zero.
+
+\item \verb|-l|, \verb|-loops COUNT|
+
+--- specify maximum number of loops the 'ip addr flush' logic will attempt
+before giving up. The default is 10.  Zero (0) means loop until all
+addresses are removed.
+
 \end{itemize}
 
 \verb|OBJECT| is the object to manage or to get information about.
-- 
2.1.0
