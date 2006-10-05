From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 0/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 05 Oct 2006 15:42:13 -0500
Message-ID: <45256E25.6020201@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	eparis@redhat.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:29373 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932110AbWJEUnr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 16:43:47 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This version takes into account David Miller's comments
regarding treatment of security layer errors in the case
of socket policies. Specifically, these errors will be
treated like how these kind of errors are treated for
the main/sub policies, which is to return a full lookup
failure.

 include/linux/security.h        |   24 ++-----
 include/net/flow.h              |    2 
 include/net/xfrm.h              |    3 
 net/core/flow.c                 |   42 ++++++++----
 net/ipv4/xfrm4_policy.c         |    2 
 net/ipv6/xfrm6_policy.c         |    2 
 net/key/af_key.c                |    5 -
 net/xfrm/xfrm_policy.c          |  101 ++++++++++++++++++++++--------
 net/xfrm/xfrm_user.c            |    9 --
 security/dummy.c                |    3 
 security/selinux/include/xfrm.h |    3 
 security/selinux/xfrm.c         |   53 ++++++++++++---
 12 files changed, 162 insertions(+), 87 deletions(-)
