From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Fri, 29 May 2015 09:50:03 +0200
Message-ID: <20150529075003.GA11638@nanopsycho.orion>
References: <555AD11E.5040709@cumulusnetworks.com>
 <20150519.123418.481170679256206928.davem@davemloft.net>
 <20150519194731.GK9559@gospo.home.greyhouse.net>
 <20150519.162845.955021778058631119.davem@davemloft.net>
 <CAE4R7bAB2+Oy92w9RpLKL5LUq7gP1mBazBK9y4ZQ4b0k8t2WhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	john fastabend <john.fastabend@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36347 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397AbbE2HuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 03:50:06 -0400
Received: by wivl4 with SMTP id l4so8922593wiv.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 00:50:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAB2+Oy92w9RpLKL5LUq7gP1mBazBK9y4ZQ4b0k8t2WhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 21, 2015 at 07:46:54AM CEST, sfeldma@gmail.com wrote:
>On Tue, May 19, 2015 at 1:28 PM, David Miller <davem@davemloft.net> wrote:
>> From: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Date: Tue, 19 May 2015 15:47:32 -0400
>>
>>> Are you actually saying that if users complain loudly enough about
>>> the current behavior (not the change Roopa has proposed) that you
>>> would be open to considering a change the current behavior?
>>
>> I am saying that we have a contract with users not to break existing
>> behavior.  Full stop.
>
>After rehearing David's argument, we should probably explore option d)
>which is a refinement on the fib_offload_disable mechanism we have
>today.  fib_offload_disable is global for all routes.  Once we hit a
>HW install problem, the global flag is set and all routes fallback to
>SW.  We did this because we can't allow the failed route to exist in
>SW and not in HW because it could mess up LPM searches (HW could hit
>on a lesser prefix even when SW has the true LPM, because HW gets
>first shot at match).  The refinement on fib_offload_disable is this:
>make it per-related-prefix rather than global, and on a HW install
>problem, set the flag for the related-prefix and uninstall only those
>routes from HW.  Related-prefix (is there a correct term for this?)
>are routes to the same dst addr but with different prefix lengths.  I
>haven't parsed the fib_trie structure to see how routes are organized,
>but I suspect since it's optimized for lookup the related-prefix
>tracking is already there and we can build on that.

This looks interesting. However, I'm not sure that it is acceptable for
user to experience this hw evict of "random entries". User knows what
entries are essential to have in hw. With your solution, I can see no way
user can actually say what should be offloaded or not. Kernel just
automagically decides.
