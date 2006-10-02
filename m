From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] genetlink custom attribute type
Date: Mon, 2 Oct 2006 15:49:13 +0200
Message-ID: <20061002134913.GB18349@postel.suug.ch>
References: <1159255520.2782.1.camel@ux156> <20060926094408.GT18349@postel.suug.ch> <1159359523.2698.27.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:16553 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932336AbWJBNsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 09:48:52 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1159359523.2698.27.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-09-27 14:18
> On Tue, 2006-09-26 at 11:44 +0200, Thomas Graf wrote:
> 
> > Thinking it over I'm still not completely happy with this. A
> > small subset of all the validation tasks is simply too complex
> > to be put into the policy. The validation of your type value
> > array is such a case, address fields with variable length based
> > on their family is another. I think it's just not worth to
> > blow up struct nla_policy by 12 bytes per entry just to save
> > some code.
> 
> Oh, I just had another idea... Feel free to ignore me if you think that
> having this done in some generic way isn't worth it though. As I said,
> it doesn't really make a difference to me in the end :)
> 
> 
> Currently, we always pass a "struct nla_policy *policy" into things,
> which really is an array. We could instead pass in a new
> 
> struct nla_validation {
> 	int (*custom_validate)(struct nlattr *nla);
> 	struct nla_policy *policy;
> };
> 
> and call custom_validate() whenever we encounter something in the policy
> that has type NLA_CUSTOM_VALIDATE. Downsides of this approach are that
> it requires changing all current users, and introduces 16 bytes constant
> overhead on 64-bit platforms, the size of nla_validation.

Sorry for the delay.

That's not a bad idea, although it seems cleaner to just allow defining
a callback function which gets called foreach unknown attribute. As for
generic netlink, this callback could be defined on a per command basis
in struct genl_ops.
