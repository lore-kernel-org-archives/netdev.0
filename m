From: Helge Deller <deller@gmx.de>
Subject: Re: [PATCH v2] soreuseport: add compat case for setsockopt
 SO_ATTACH_REUSEPORT_CBPF
Date: Fri, 3 Jun 2016 23:49:17 +0200
Message-ID: <20160603214917.GA12557@ls3530.box>
References: <CAEfhGiwwvwf31Dj+s0zA0bpVAZ4x4=rLuU5g217u=wRrgm07Dg@mail.gmail.com>
 <20160603214002.GA58242@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Craig Gallek <kraigatgoog@gmail.com>, Helge Deller <deller@gmx.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:58516 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964770AbcFCVte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 17:49:34 -0400
Content-Disposition: inline
In-Reply-To: <20160603214002.GA58242@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
missed to add the compat case for the SO_ATTACH_REUSEPORT_CBPF option.

Signed-off-by: Helge Deller <deller@gmx.de>

diff --git a/net/compat.c b/net/compat.c
index 5cfd26a..1373947 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -354,7 +354,8 @@ static int do_set_sock_timeout(struct socket *sock, int level,
 static int compat_sock_setsockopt(struct socket *sock, int level, int optname,
 				char __user *optval, unsigned int optlen)
 {
-	if (optname == SO_ATTACH_FILTER)
+	if (optname == SO_ATTACH_FILTER ||
+	    optname == SO_ATTACH_REUSEPORT_CBPF)
 		return do_set_attach_filter(sock, level, optname,
 					    optval, optlen);
 	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
