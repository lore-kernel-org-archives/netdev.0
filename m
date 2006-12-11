From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS) returns
 -1
Date: Mon, 11 Dec 2006 09:56:23 -0800
Message-ID: <20061211095623.09fb0c40.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:49295 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937379AbWLKR4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 12:56:25 -0500
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id kBBHuNID024605
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 09:56:24 -0800
Received: from box (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id kBBHuN13001300
	for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 09:56:23 -0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 11 Dec 2006 07:18:20 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS) returns -1


http://bugzilla.kernel.org/show_bug.cgi?id=7665

           Summary: getsockopt(IPV6_*CAST_HOPS) returns -1
    Kernel Version: 2.6.19
            Status: NEW
          Severity: normal
             Owner: yoshfuji@linux-ipv6.org
         Submitter: rdenis@simphalempin.com


Most recent kernel where this bug did *NOT* occur: N/A
Distribution: Debian Sid
Hardware Environment: i386
Software Environment: glibc 2.3.6
Problem Description:

Where fd is a socket (datagram or raw) with IPv6 protocol family,
getsockopt(fd, IPPROTO_IPV6, IPV6_UNICAST_HOPS, ...) succeeds, but the returned 
hop limit is -1. connect()'ing the socket first does not solve the problem.

Same problem with IPV6_MULTICAST_HOPS.

Steps to reproduce:

Compile and run the following test case:

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main (void)
{
        int fd, val;
        socklen_t len = sizeof (val);
        struct sockaddr_in6 addr;

        memset (&addr, 0, sizeof (addr));
        fd = socket (AF_INET6, SOCK_RAW, IPPROTO_UDP);
        addr.sin6_family = AF_INET6;
        addr.sin6_addr.s6_addr[15] = 1;
        connect (fd, (struct sockaddr *)&addr, sizeof (addr));

        if (fd == -1) return 1;
        if (getsockopt (fd, IPPROTO_IPV6, IPV6_UNICAST_HOPS, &val, &len) == 0)
                printf ("Default unicast hops limit: %d\n", val);
        if (getsockopt (fd, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, &val, &len) == 
0)
                printf ("Default multicast hops limit: %d\n", val);
        return 0;
}

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
