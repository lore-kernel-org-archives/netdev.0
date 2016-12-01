From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 04/18] ss: Use sockstat->type in all socket
 types
Date: Thu, 1 Dec 2016 10:41:01 -0800
Message-ID: <20161201104101.05566d92@xeon-e3>
References: <20161111131014.21865-1-phil@nwl.cc>
        <20161111131014.21865-5-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35273 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756233AbcLASlQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:41:16 -0500
Received: by mail-pf0-f182.google.com with SMTP id i88so47274515pfk.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:41:16 -0800 (PST)
In-Reply-To: <20161111131014.21865-5-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Nov 2016 14:10:00 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Unix sockets used that field already to hold info about the socket type.
> By replicating this approach in all other socket types, we can get rid
> of protocol parameter in inet_stats_print() and have sock_state_print()
> figure things out by itself.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Cleaning out the patch backlog...
This patch does not apply to current master branch, rejects are:

--- misc/ss.c
+++ misc/ss.c
@@ -1719,27 +1768,11 @@ void *parse_markmask(const char *markmask)
 	return res;
 }
 
-static char *proto_name(int protocol)
-{
-	switch (protocol) {
-	case 0:
-		return "raw";
-	case IPPROTO_UDP:
-		return "udp";
-	case IPPROTO_TCP:
-		return "tcp";
-	case IPPROTO_DCCP:
-		return "dccp";
-	}
-
-	return "???";
-}
-
-static void inet_stats_print(struct sockstat *s, int protocol)
+static void inet_stats_print(struct sockstat *s)
 {
 	char *buf = NULL;
 
-	sock_state_print(s, proto_name(protocol));
+	sock_state_print(s);
 
 	inet_addr_print(&s->local, s->lport, s->iface);
 	inet_addr_print(&s->remote, s->rport, 0);


Please fix and resubmit whole series.
