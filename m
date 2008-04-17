From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: catch signed nla_len() retval in tcf_simp_init()
Date: Thu, 17 Apr 2008 08:58:33 -0400
Message-ID: <1208437113.4420.34.camel@localhost>
References: <4806C501.20300@tiscali.nl>
	 <20080416.213712.78410382.davem@davemloft.net> <4806D847.2030806@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, 12o3l@tiscali.nl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:37715 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754988AbYDQM6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 08:58:40 -0400
Received: by an-out-0708.google.com with SMTP id d31so12951and.103
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 05:58:37 -0700 (PDT)
In-Reply-To: <4806D847.2030806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-04 at 06:55 +0200, Patrick McHardy wrote:

> The change is also unnecessary because the attribute was
> already validated and the length can not be less than zero.

Since act_simple is an academic example:
I think that a better solution is to add TCA_DEF_DATA (which is a
string) to the nla_policy. nla_policy is defined but at the moment it is
not used in the call to nla_parse_nested() - might as well use it.

Roel, would you like to take a crack at that? You will need to define
the max size of the string that TCA_DEF_DATA can hold (if you want to do
it cleanly then define it in include/linux/tc_act/tc_defact.h). This MAX
size will appear in the nla_policy.

cheers,
jamal

