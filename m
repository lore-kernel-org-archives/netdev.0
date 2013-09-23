From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/12] ping.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 19:16:39 -0700
Message-ID: <1379902599.3575.9.camel@joe-AO722>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
	 <523FA098.9050200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Ryan Mallon <rmallon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0192.hostedemail.com ([216.40.44.192]:46688 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753020Ab3IWCQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 22:16:44 -0400
In-Reply-To: <523FA098.9050200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 11:59 +1000, Ryan Mallon wrote:
> This seems like a lot of code churn for very little benefit. At a quick
> glance:
> 
>   git grep extern include/ | wc -l
>   11427
> 
> Not all of those will need to be removed, but that is still a huge
> number to change, and doesn't include extern usage in C files or local
> headers. You are probably never going to remove all the instances, so
> what is the point of just randomly doing a handful?

Rather more than a handful.

The ratio of function prototypes without extern to
function prototypes with extern is currently ~2.5:1

So:

Standardization without extern
Line count reduction (~10%)
Miscellaneous neatening at the same time
Removal of all unnecessary externs from include/net

There are ~8500 instances in include/
There are ~1500 instances in include/net/

After this series, 0 in include/net/

Start somewhere, go from there...

$ git grep -E "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" include/ | wc -l
8395
$ git grep -E "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" include/net/ | wc -l
1471
