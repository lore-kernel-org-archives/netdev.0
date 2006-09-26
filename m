From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] genetlink custom attribute type
Date: Tue, 26 Sep 2006 11:44:08 +0200
Message-ID: <20060926094408.GT18349@postel.suug.ch>
References: <1159255520.2782.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:64432 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750965AbWIZJns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 05:43:48 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1159255520.2782.1.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-09-26 09:25
> This patch adds an NLA_CUSTOM_CHECK type for netlink attributes
> in order to be able to centrally define new attribute structures
> instead of having to check these special types in each function
> that uses such an attribute.

Thinking it over I'm still not completely happy with this. A
small subset of all the validation tasks is simply too complex
to be put into the policy. The validation of your type value
array is such a case, address fields with variable length based
on their family is another. I think it's just not worth to
blow up struct nla_policy by 12 bytes per entry just to save
some code.
