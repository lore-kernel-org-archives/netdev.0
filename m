From: Matthew Burgess <matthew@linuxfromscratch.org>
Subject: Compilation issues using netlink.h
Date: Mon, 28 Dec 2009 00:32:51 +0000
Message-ID: <4B37FCB3.9000800@linuxfromscratch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ben@decadent.org.uk,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp823.mail.ird.yahoo.com ([217.146.188.233]:48763 "HELO
	smtp823.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751192AbZL1Ajn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 19:39:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The test case below simplifies a failure I see when trying to compile 
strace using kernel headers from Linux-2.6.32.2:

#include <linux/netlink.h>
struct sockaddr_nl nl;
int main() {
   return 0;
}

$ gcc -o test test.c
In file included from test.c:1:
/usr/include/linux/netlink.h:34: error: expected 
specifier-qualifier-list before 'sa_family_t'

The comment in netlink.h suggests that 'sa_family_t' is expected to be 
found in linux/socket.h, but since commit 9c501935a3 ("net: Support 
inclusion of <linux/socket.h> before <sys/socket.h>") that appears to 
not be true anymore, it's now in sys/socket.h.  Sure enough, if I change 
the include in netlink.h to pull in sys/socket.h instead of 
linux/socket.h, that enables the test case (and strace) to compile 
again, but I wasn't sure if it was really the right thing to do.

Thanks,

Matt.
