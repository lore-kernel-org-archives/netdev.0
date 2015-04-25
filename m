From: Felix Janda <felix.janda@posteo.de>
Subject: iproute2: Make linux/in6.h a stub?
Date: Sat, 25 Apr 2015 22:54:11 +0200
Message-ID: <20150425205410.GB9433@euler>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.posteo.de ([89.146.194.165]:35993 "EHLO mx02.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbbDYUyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Apr 2015 16:54:18 -0400
Received: from dovecot03.posteo.de (unknown [185.67.36.28])
	by mx02.posteo.de (Postfix) with ESMTPS id AF6FD25AF503
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 22:54:16 +0200 (CEST)
Received: from mail.posteo.de (localhost [127.0.0.1])
	by dovecot03.posteo.de (Postfix) with ESMTPSA id 3lZ4Nm2nLSz5vNB
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 22:54:16 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Background:
Current iproute2 does not build when the libc is musl instead of glibc.
This is because of redefinition of in6_addr in netinet/in.h and
linux/in6.h. There are workarounds in linux/libc-compat.h to make it
somehow work for glibc.


As I can see linux/in6.h is only indirectly used via the other kernel
headers linux/if_bridge.h and linux/xfrm.h. These in turn include
linux/in6.h only in order to get a declaration of in6_addr.

Since iproute2 depends on the fact that in6_addr is defined in
<netinet/in.h> it should be safe to replace the content of linux/in6.h
by

#include <netinet/in.h>

This completely removes the possibility for redefinition of in6_addr
for any libc. Since linux/in6.h is anyway a patched kernel header, such
a change should also not increase the work needed to sync with newer
kernel headers.

Would it be possible to implement such a change?

Felix
