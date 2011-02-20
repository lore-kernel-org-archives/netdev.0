From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH]tcp: document tcp_max_ssthresh (Limited Slow-Start)
Date: Sun, 20 Feb 2011 15:52:41 +0800
Message-ID: <4D60C849.40905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>, jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54574 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751702Ab1BTHze convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 02:55:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Base on Ilpo's patch about documenting tcp_max_ssthresh.
(see http://marc.info/?l=3Dlinux-netdev&m=3D117950581307310&w=3D2)

According to errata of RFC3742, fix the number of segments increased=20
during RTT time.=20

Just to state the occasion to use this parameter, But
about how to set parameter value, maybe some others can do it.=20


Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 Documentation/networking/ip-sysctl.txt |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index ac3b4a7..ea78aac 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -280,6 +280,17 @@ tcp_max_orphans - INTEGER
 	more aggressively. Let me to remind again: each orphan eats
 	up to ~64K of unswappable memory.
=20
+tcp_max_ssthresh - INTEGER
+	Limited Slow-Start for TCP with large congestion windows (cwnd) defin=
ed in
+	RFC3742. Limited slow-start is a mechanism to limit growth of the cwn=
d
+	on the region where cwnd is larger than tcp_max_ssthresh. TCP increas=
es cwnd
+	by at most tcp_max_ssthresh segments, and by at least tcp_max_ssthres=
h/2
+	segments per RTT when the cwnd is above tcp_max_ssthresh.
+	If TCP connection increased cwnd to thousands (or tens of thousands) =
segments,
+	and thousands of packets were being dropped during slow-start, you ca=
n set
+	tcp_max_ssthresh to improve performance for new TCP connection.
+	Default: 0 (off)
+
 tcp_max_syn_backlog - INTEGER
 	Maximal number of remembered connection requests, which are
 	still did not receive an acknowledgment from connecting client.
--=20
1.6.3.3
