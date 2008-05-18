From: Jan Engelhardt <jengelh@medozas.de>
Subject: IPV6_V6ONLY ignored for SCTP
Date: Sun, 18 May 2008 12:58:55 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0805181244480.15590@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:42905 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbYERK65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 06:58:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by sovereign.computergmbh.de (Postfix) with ESMTP id D74A21CD52C28
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 12:58:55 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


with the following short C program, I get "Address already in use"
(when binding 'b'), but only when using IPPROTO_SCTP. When I use 
IPPROTO_TCP for 'a' and 'b', everything is fine. Seems like SCTP
is ignoring the V6ONLY flag.
Running kernel is 2.6.25.3 on i686. Any other info needed?

Thanks,
Jan

--<<---
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdio.h>
#define p(x) if ((x) < 0) perror("urgh")
int main(void)
{
	int a, b, y = 1;
	p(a = socket(PF_INET, SOCK_STREAM, IPPROTO_SCTP));
	p(b = socket(PF_INET6, SOCK_STREAM, IPPROTO_SCTP));
	p(setsockopt(b, IPPROTO_IPV6, IPV6_V6ONLY, &y, sizeof(y)));
	p(bind(a, (const void *)&(struct sockaddr_in){.sin_family = PF_INET,
		.sin_port = htons(3333)}, sizeof(struct sockaddr_in)));
	p(listen(a, SOMAXCONN));
	p(bind(b, (const void *)&(struct sockaddr_in6){.sin6_family = PF_INET6,
		.sin6_port = htons(3333)}, sizeof(struct sockaddr_in6)));
	p(listen(b, SOMAXCONN));
	return 0;
}
