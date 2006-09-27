From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink custom attribute type
Date: Wed, 27 Sep 2006 14:18:42 +0200
Message-ID: <1159359523.2698.27.camel@ux156>
References: <1159255520.2782.1.camel@ux156>
	 <20060926094408.GT18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33231 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030210AbWI0MR6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 08:17:58 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060926094408.GT18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-26 at 11:44 +0200, Thomas Graf wrote:

> Thinking it over I'm still not completely happy with this. A
> small subset of all the validation tasks is simply too complex
> to be put into the policy. The validation of your type value
> array is such a case, address fields with variable length based
> on their family is another. I think it's just not worth to
> blow up struct nla_policy by 12 bytes per entry just to save
> some code.

Oh, I just had another idea... Feel free to ignore me if you think that
having this done in some generic way isn't worth it though. As I said,
it doesn't really make a difference to me in the end :)


Currently, we always pass a "struct nla_policy *policy" into things,
which really is an array. We could instead pass in a new

struct nla_validation {
	int (*custom_validate)(struct nlattr *nla);
	struct nla_policy *policy;
};

and call custom_validate() whenever we encounter something in the policy
that has type NLA_CUSTOM_VALIDATE. Downsides of this approach are that
it requires changing all current users, and introduces 16 bytes constant
overhead on 64-bit platforms, the size of nla_validation.

johannes
