From: Michel Machado <michel@digirati.com.br>
Subject: include/linux/netlink.h: problem when included by an application
Date: Fri, 05 Aug 2011 17:45:48 -0400
Message-ID: <1312580748.2326.15.camel@Thor>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta63.f1.k8.com.br ([187.16.23.95]:43530 "EHLO
	mta63.f1.k8.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102Ab1HEWOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 18:14:02 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtpl.f1.k8.com.br (Postfix) with ESMTP id A2848200A155
	for <netdev@vger.kernel.org>; Fri,  5 Aug 2011 21:45:51 +0000 (GMT)
Received: from smtpl.f1.k8.com.br ([127.0.0.1])
	by localhost (mta63.f1.k8.com.br [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id k7M4RCwAR25P for <netdev@vger.kernel.org>;
	Fri,  5 Aug 2011 21:45:51 +0000 (GMT)
Received: from [192.168.10.104] (c-76-127-142-250.hsd1.ma.comcast.net [76.127.142.250])
	by smtpl.f1.k8.com.br (Postfix) with ESMTPA id E6524200A140
	for <netdev@vger.kernel.org>; Fri,  5 Aug 2011 21:45:50 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

   When an application includes header <linux/netlink.h> obtained with
'make headers_install' or from /usr/include/, it produces the following
error:

/usr/include/linux/netlink.h:31:2: error: expected
specifier-qualifier-list before =E2=80=98sa_family_t=E2=80=99

   The error doesn't come up in the kernel because
include/linux/netlink.h has the following line:

#include <linux/socket.h> /* for sa_family_t */

   However, <linux/socket.h> from /usr/include/ doesn't have sa_family_=
t
because it's protected by an $ifdef __KERNEL__ in
include/linux/socket.h.

   A workaround for an application is to include <sys/socket.h> before
<linux/netlink.h>. However, shouldn't include/linux/netlink.h be fixed?

   The simplest solution that I came up was replacing sa_family_t in
include/linux/netlink.h to 'unsigned short' as header
include/linux/socket.h does for struct __kernel_sockaddr_storage
available to applications.

--=20
[ ]'s
Michel Machado



