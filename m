From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] ip, route: fix minor compile warning
Date: Fri, 18 Dec 2015 10:18:23 +0100
Message-ID: <5673CF5F.1060806@iogearbox.net>
References: <c43f41f31854bb0a27cc6cd6d9e465a28a94ffb9.1450106992.git.daniel@iogearbox.net>	<20151214155104.GE6555@orbit.nwl.cc>	<566EE5F0.9030504@iogearbox.net> <20151217171203.723b4d16@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60703 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966463AbbLRJS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 04:18:26 -0500
In-Reply-To: <20151217171203.723b4d16@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2015 02:12 AM, Stephen Hemminger wrote:
> On Mon, 14 Dec 2015 16:53:20 +0100
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> On 12/14/2015 04:51 PM, Phil Sutter wrote:
>>> On Mon, Dec 14, 2015 at 04:34:29PM +0100, Daniel Borkmann wrote:
>>>> Seems like gcc (4.8.3) doesn't catch this false positive, triggering
>>>> after 0f7543322c5f ("route: ignore RTAX_HOPLIMIT of value -1"):
>>>>
>>>>     iproute.c: In function 'print_route':
>>>>     iproute.c:301:12: warning: 'val' may be used uninitialized in this function [-Wmaybe-uninitialized]
>>>>        features &= ~RTAX_FEATURE_ECN;
>>>>                 ^
>>>>     iproute.c:575:10: note: 'val' was declared here
>>>>         __u32 val;
>>>>               ^
>>>> So just shut it up by initializing to 0.
>>>
>>> Hmm. Interestingly, my patch shouldn't have changed anything relevant
>>> for gcc's decision. OTOH, I don't see a warning using gcc-4.9.3.
>>
>> If I revert it, the warning is gone for me ;) perhaps some heuristic issue
>> with that gcc version.
>>
>> Cheers,
>> Daniel
>
> I don't see this warning on current master with gcc 4.9.2.

Well, in the commit message I wrote 4.8.3 ... but I don't mind if we drop it, sure.
