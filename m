From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Network namespace and tc?
Date: Wed, 13 Feb 2008 15:59:03 -0800
Message-ID: <20080213155903.4ab6e454@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38032 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932831AbYBMX7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 18:59:08 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 39F0F4F804E
	for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 15:59:08 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uCPrtSCp2zaa for <netdev@vger.kernel.org>;
	Wed, 13 Feb 2008 15:59:05 -0800 (PST)
Received: from extreme (75-175-36-245.ptld.qwest.net [75.175.36.245])
	by mail.vyatta.com (Postfix) with ESMTP id C3B5E4F8023
	for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 15:59:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like tc filter won't work on alternate namespaces:
/* Add/change/delete/get a filter node */

static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
{
...

	if (net != &init_net)
		return -EINVAL;


Haven't played with namespace virtualization yet, but what else is
not supported?  Where is this documented?
