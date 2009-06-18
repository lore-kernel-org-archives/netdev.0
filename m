From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: wireless netns work
Date: Thu, 18 Jun 2009 14:43:27 -0700
Message-ID: <43e72e890906181443g54269d1bm7ce24dcb46e7e921@mail.gmail.com>
References: <1245328543.13790.31.camel@johannes.local> <1245329713.13790.37.camel@johannes.local>
	<40f31dec0906181016nffa031flac8f464c929f1bc9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Nick Kossifidis <mickflemm@gmail.com>,
	Georgy Berdyshev <codingmaster@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:29963 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756444AbZFRVnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 17:43:45 -0400
In-Reply-To: <40f31dec0906181016nffa031flac8f464c929f1bc9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2009 at 10:16 AM, Nick Kossifidis<mickflemm@gmail.com> wrote:
> 2009/6/18 Johannes Berg <johannes@sipsolutions.net>:
>> On Thu, 2009-06-18 at 14:35 +0200, Johannes Berg wrote:
>>
>>> Oddly, the link works unidirectionally in both directions, if I ping
>>> from either side tcpdump shows the echo requests on the other side, but
>>> no echo reply is being generated. Still investigating why this is, since
>>> it works fine with veth. Ideas why this is broken would be
>>> appreciated :)
>>
>> Ok, the missing piece of the puzzle is this patch:
>> http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-hwsim-skb-cleanup.patch
>>
>> root@(none):~# ping -Q 0x80 10.0.0.1
>> PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
>> Warning: time of day goes back (-311263us), taking countermeasures.
>> 64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.487 ms
>> 64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.122 ms
>> 64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=0.121 ms
>> 64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=0.130 ms
>>
>
> Well done !!!
>
> Don't you think it's time we create a mac80211 test suite based on hwsim ?
> I think it's an interesting project...

Certainly, there's a GSOC project going on for exactly this purpose:

http://wireless.kernel.org/en/developers/GSoC/2009/Automation_of_testing

Cc'ing the student working on it, Georgy.

BTW : a good review of when namespace stuff started to get merged:

http://lwn.net/Articles/219794/

By reading this still I am still unclear what to cheer for with my pom
poms. Can you clarify a little what this means for wireless? Let me
explain a little where I am confused

For example, I see you used mac80211_hwsim and was able to use two
wlan interfaces to talk to each other. This seems great for testing
purposes but it remains unclear to me the advantage of testing with
separate namespaces vs creating two wlan interfaces on one namespace
with mac80211_hwsim.

Also, it remains unclear to me what the implications for real device
usage though. So for example ath9k has support creating multiple
wiphys and it uses its own schedular to also support communication on
two separate channels. Does supporting different namespaces have
implication on how we can support multiple wiphys in the future? Mind
you I have yet to review all the patches, but if you create a
secondary namespace and have a mac80211 wireless driver loaded how
does sharing the device work?

  Luis
