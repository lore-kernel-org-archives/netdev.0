From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] ip, route: fix minor compile warning
Date: Mon, 14 Dec 2015 16:53:20 +0100
Message-ID: <566EE5F0.9030504@iogearbox.net>
References: <c43f41f31854bb0a27cc6cd6d9e465a28a94ffb9.1450106992.git.daniel@iogearbox.net> <20151214155104.GE6555@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51391 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbbLNPxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 10:53:23 -0500
In-Reply-To: <20151214155104.GE6555@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2015 04:51 PM, Phil Sutter wrote:
> On Mon, Dec 14, 2015 at 04:34:29PM +0100, Daniel Borkmann wrote:
>> Seems like gcc (4.8.3) doesn't catch this false positive, triggering
>> after 0f7543322c5f ("route: ignore RTAX_HOPLIMIT of value -1"):
>>
>>    iproute.c: In function 'print_route':
>>    iproute.c:301:12: warning: 'val' may be used uninitialized in this function [-Wmaybe-uninitialized]
>>       features &= ~RTAX_FEATURE_ECN;
>>                ^
>>    iproute.c:575:10: note: 'val' was declared here
>>        __u32 val;
>>              ^
>> So just shut it up by initializing to 0.
>
> Hmm. Interestingly, my patch shouldn't have changed anything relevant
> for gcc's decision. OTOH, I don't see a warning using gcc-4.9.3.

If I revert it, the warning is gone for me ;) perhaps some heuristic issue
with that gcc version.

Cheers,
Daniel
