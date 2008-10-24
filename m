From: Brice Goglin <brice@myri.com>
Subject: [RFC] per-nic module parameters
Date: Fri, 24 Oct 2008 22:09:35 +0200
Message-ID: <49022B7F.8080809@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1805 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753013AbYJXUKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 16:10:40 -0400
Received: from [172.31.134.203] (brice-ovpn.sw.myri.com [172.31.134.203])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m9OKAaOM016162
	for <netdev@vger.kernel.org>; Fri, 24 Oct 2008 13:10:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We're working on making myri10ge module parameters per-nic. It looks
like ixgb already does so with the following macro in ixgb_param.c:

#define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
#define IXGB_PARAM(X, desc)                                     \
        static int __devinitdata X[IXGB_MAX_NIC+1]              \
                = IXGB_PARAM_INIT;                              \
        static unsigned int num_##X = 0;                        \
        module_param_array_named(X, X, int, &num_##X, 0);       \
        MODULE_PARM_DESC(X, desc);

Is this the recommended way to implement per-nic module params? Or
should we do something else?

Thanks,
Brice

