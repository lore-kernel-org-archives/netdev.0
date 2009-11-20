From: Philip Prindeville <philipp@redfish-solutions.com>
Subject: Question about IP_TOS and DSCP handling
Date: Fri, 20 Nov 2009 15:55:49 -0700
Message-ID: <4B071E75.1030103@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:36804 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753166AbZKTWzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:55:43 -0500
Received: from [192.168.1.3] (mail.redfish-solutions.com [192.168.1.3])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.3/8.14.3) with ESMTP id nAKMtnJG022130
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:55:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking at net/ipv4/ip_sockglue.c circa line 512 (this is in 2.6.27.38):

        case IP_TOS:    /* This sets both TOS and Precedence */
                if (sk->sk_type == SOCK_STREAM) {
                        val &= ~3;
                        val |= inet->tos & 3;
                }
                if (inet->tos != val) {
                        inet->tos = val;
                        sk->sk_priority = rt_tos2priority(val);
                        sk_dst_reset(sk);
                }
                break;


and it doesn't look like the kernel handles DSCP marking. Is that
correct?  (Also, not clear why SOCK_STREAM gets handled differently...)

Looking at rt_tos2priority(), which uses IPTOS_TOS(x), it doesn't look
like that would be the correct thing to do.

Also, include/linux/ip.h no longer meshes with
/usr/include/netinet/in.h. Please see:

http://sourceware.org/bugzilla/show_bug.cgi?id=10789

I'm trying to add DSCP marking to Thunderbird, Firefox, Apache, and a
few other applications but I wanted to make sure that my test platforms
would handle it correctly first.

Thanks,

-Philip



