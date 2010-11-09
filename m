From: Ben Greear <greearb@candelatech.com>
Subject: Re: Networking hangs when too many parallel requests are made at
 once
Date: Tue, 09 Nov 2010 14:49:19 -0800
Message-ID: <4CD9CFEF.5090009@candelatech.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com> <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com> <4CD99E20.4060307@candelatech.com> <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com> <4CD9B09B.8040906@candelatech.com> <AANLkTinu4=Ox_vA_yr7vbdbcqr4P7oS+zMX_yaXhK4E9@mail.gmail.com> <4CD9C7E2.6050909@candelatech.com> <AANLkTi=qgJcBUdhDpV8QdPPUO1o7QjZLUj07_C1B9Ygg@mail.gmail.com> <4CD9CB44.4030206@candelatech.com> <AANLkTi=LGx2mbYT5gRMV0izg5=KY7pCKOuXnwPRNQDMK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luke Hutchison <luke.hutch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42464 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864Ab0KIWtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 17:49:20 -0500
In-Reply-To: <AANLkTi=LGx2mbYT5gRMV0izg5=KY7pCKOuXnwPRNQDMK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2010 02:38 PM, Luke Hutchison wrote:
> On Tue, Nov 9, 2010 at 5:29 PM, Ben Greear<greearb@candelatech.com>  wrote:
>> If you get all names resolved with your caching name-server, can you then
>> open the browser tabs w/out problem?
>
> This is hard to test, because to get all the same domain names
> resolved for all resources on all pages, I have to successfully open
> all the pages once first.  Even opening the pages a few seconds apart
> seems to break things quite frequently.  And there is a period where
> the connection starts acting up but is not hard locked up, and it's
> hard to know at that point if it's the connection or the individual
> website.  The only way I can think of of reliably triggering this 100%
> of the time is to open a bunch of browser tabs all at the same time --
> and that hangs the dns caching server's requests too.
>
>> Have you tried setting all your browser tabs to simple low-bandwidth pages (no ads being
>> served from various hosts, etc) to see if that works?
>
> Not exactly, but I have one browser window with about 20 Wikipedia
> articles open, and not all of them load (some get stalled until they
> time out).  I think this serves the same purpose as your suggested
> test, because Wikipedia doesn't draw from many external domains.
>
>> Maybe you are just flooding the network so hard that responses are being
>> dropped?
>
> Yes, but you pointed out earlier that you routinely test with
> thousands of TCP connections, and we're only talking about 20-30
> browser tabs here, maybe a few thousand HTTP requests at most.  Also,
> this used to work fine on old Fedora kernels and no longer works with
> more recent kernels.

Well, I'm low on ideas.

For our tests though, we are running across 1G Ethernet most of the time,
so bandwidth is not an issue.  Also, we aren't dependent on external DNS for
this type of test.

 From looking at your capture, you are not getting DNS responses back
reliably.  On the great wild internet, there are lots of reasons why
that might be happening, so without a more controlled test case, I'm
not sure anyone can help you.

It wouldn't be quick, but if you were able to do a git-bisect to figure
out which kernel change affected you, then that might be a start.

If there were a way for you to tune your TCP stack to run slower, that
might help too.  Maybe hard limit the max window size to something small like
8k?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

