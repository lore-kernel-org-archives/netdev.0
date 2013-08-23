From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] genl: Hold reference on correct module while
 netlink-dump.
Date: Fri, 23 Aug 2013 09:23:45 +0200
Message-ID: <1377242625.14021.5.camel@jlt4.sipsolutions.net>
References: <1377206741-18400-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:38013 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab3HWHXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 03:23:47 -0400
In-Reply-To: <1377206741-18400-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +extern int __genl_register_family(struct genl_family *family, struct module *module);

Why add an extra argument instead of just assigning family->module in
the inline wrapper(s):

static inline int genl_register_family(struct genl_family *family)
{
	family->module = THIS_MODULE;
	return __genl_register_family(family);
}

Although I guess it doesn't really make a big difference. Just curious
if there was a reason you decided to do it this way.

johannes
