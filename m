From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: module_param: make bool parameters really bool (net &
 drivers/net)
Date: Thu, 22 Mar 2012 21:26:23 +0300
Message-ID: <20120322182623.GA29859@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:47968 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757099Ab2CVS0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 14:26:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

The patch eb93992207da: "module_param: make bool parameters really
bool (net & drivers/net)" from Dec 19, 2011, leads to the following
warning:
net/ipv4/netfilter/iptable_filter.c:90 iptable_filter_init()
	warn: 5 is more than 1 (max 'forward' can be) so this is
	always the same.

It's declared like this:

    54  /* Default to forward because I got too much mail already. */
    55  static bool forward = NF_ACCEPT;
    56  module_param(forward, bool, 0000);


It's used like this:
    66          ((struct ipt_standard *)repl->entries)[1].target.verdict = -forward - 1;

Smatch complains when check that it's larger than 5.

    90          if (forward < 0 || forward > NF_MAX_VERDICT) {
    91                  pr_err("iptables forward must be 0 or 1\n");
    92                  return -EINVAL;
    93          }

regards,
dan carpenter
