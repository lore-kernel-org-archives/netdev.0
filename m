From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH 01/12] ping.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 12:38:06 +1000
Message-ID: <523FA98E.4080908@gmail.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>  <523FA098.9050200@gmail.com> <1379902599.3575.9.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:46138 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab3IWCiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 22:38:09 -0400
In-Reply-To: <1379902599.3575.9.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/09/13 12:16, Joe Perches wrote:
> On Mon, 2013-09-23 at 11:59 +1000, Ryan Mallon wrote:
>> This seems like a lot of code churn for very little benefit. At a quick
>> glance:
>>
>>   git grep extern include/ | wc -l
>>   11427
>>
>> Not all of those will need to be removed, but that is still a huge
>> number to change, and doesn't include extern usage in C files or local
>> headers. You are probably never going to remove all the instances, so
>> what is the point of just randomly doing a handful?
> 
> Rather more than a handful.
> 
> The ratio of function prototypes without extern to
> function prototypes with extern is currently ~2.5:1
> 
> So:
> 
> Standardization without extern
> Line count reduction (~10%)
> Miscellaneous neatening at the same time
> Removal of all unnecessary externs from include/net
> 
> There are ~8500 instances in include/
> There are ~1500 instances in include/net/
> 
> After this series, 0 in include/net/
> 
> Start somewhere, go from there...
> 
> $ git grep -E "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" include/ | wc -l
> 8395
> $ git grep -E "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" include/net/ | wc -l
> 1471

Right, and:

  $ git grep -E "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" | wc -l
  29104

Since there are lots of local/arch headers, and there are uses of extern
function prototypes in C files.

I don't see the real benefit though. Its like trying to "clean-up" the
difference between "unsigned x" and "unsigned int x", or any number of
other minor style differences. Either version, with or without the
extern, is correct, valid C code. Plus you will get people adding new
instances of extern because they don't know any better. A checkpatch
rule might help, but we all know how often people run that...

~Ryan
