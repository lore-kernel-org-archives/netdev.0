From: Vadim Kochan <vadim4j@gmail.com>
Subject: iproute2 util: Change signature of rtnl dump filters to use struct params
Date: Wed, 3 Sep 2014 02:46:50 +0300
Message-ID: <CAMw6YJJq1MP+r6=8KrhBi9bPUS8E1JJjb3qOjbjVf4Ano0AVsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:33108 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaIBXqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 19:46:51 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so7960981qcx.27
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 16:46:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am thinking about to make some refactoring and change the signature
of all rtnl dump filters to form:

diff --git a/include/libnetlink.h b/include/libnetlink.h
index fe7d5d3..9514e67 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -39,8 +39,14 @@ extern int rtnl_dump_request(struct rtnl_handle
*rth, int type, void *req,
                             int len)
        __attribute__((warn_unused_result));

-typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
-                            struct nlmsghdr *n, void *);
+struct nl_param
+{
+       struct sockaddr_nl *who;
+       struct nlmsghdr *n;
+       void *arg;
+};
+
+typedef int (*rtnl_filter_t)(struct nl_param *p);

 struct rtnl_dump_filter_arg
 {

What do you think?

Regards,
