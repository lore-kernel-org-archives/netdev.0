From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Subject: Re: RFC: Established connections hash function
Date: Thu, 22 Mar 2007 12:44:09 -0700
Message-ID: <1199CE22A40740D28833A585014BE559@XEON>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <20070322155227.GA18557@2ka.mipt.ru> <391F64D0A7C5463CA2D70362E4B3E7EC@XEON> <20070322182156.GB17793@2ka.mipt.ru>
Reply-To: nikb@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="koi8-r";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:1665 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934203AbXCVTpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:45:16 -0400
Received: from XEON by webmaster.com
	(Cipher TLSv1:RC4-MD5:128) (MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50001457444.msg
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 12:44:26 -0800
In-Reply-To: <20070322182156.GB17793@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 11:21 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

>>    Utterly broken? Nonsense. I have tested the actual function I proposed
>> (sans the __force and __u32 stuff, which weren't necessary in my test
>> program), against real data, collected from various servers in real-time.
>> It has consistently achieved lower average chain lengths than the vanilla
>> function and demonstrated no artifacting, and that's trivial to verify.
>
> So what?

    So what? Are you serious?


> People test and work with XOR hash for years and they do not strike any
> problems. If we talk about specially crafted data, then XOR one is no
> worse than Jenkins with 3 words (which is even worse for blind attack of
> constant ports).

    People _have_ had problems. _I_ have had problems. And when someone with 
a few thousand drones under his control hoses your servers because he can do 
math and he leaves you with 20000-item long chains, _you_ will have 
problems. And sticking your head in the sand and saying "people work with 
XOR hash for years and they do not strike any problems" wont help you.


>>    The only analysis I could find was this
>> http://tservice.net.ru/~s0mbre/blog/2006/05/14#2006_05_14, which uses
>> jhash_2words, and not jhash_3words, and which naively attempts to take 
>> the
>> output of jhash_2words, and to perform the same mixing trick that the
>> vanilla inet_ehashfn does and uses artificially generated data sets.
>
> It is outdated, check recent netdev@ archives. Folding used in that test
> does not change distribution, and data was presented as it can be
> selected by attacker, who can create with any distribution.

    Be careful here. If the folding makes no difference, it says something 
very important about __jhash_mix, and that something goes against the very 
thing that you are saying.


>>    But please, feel free to point out any other _unfavorable_ analyses of
>> jhash_2words or jhash_3words that I may have missed.
>>
>>
>> >We can use jhash_2words(laddr, faddr, portpair^inet_ehash_rnd) though.
>>
>>    Please explain to me how jhash_2words solves the issue that you claim
>> jhash_3words has, when they both use the same underlying bit-mixer?
>
> $c value is not properly distributed and significanly breaks overall
> distribution. Attacker, which controls $c (and it does it by controlling
> ports), can significantly increase selected hash chains.

    I've tested the Jenkins hash extensively. I see no evidence of this 
"improper distribution" that you describe. In fact, about the only person 
that I've seen advocate this in the archives of netdev is you, and a lot of 
other very smart people disagree with you, so I consider myself to be in 
good company.


> But it is only $c, $a and $b are properly distributed, so jhash_2words()
> is safer than jhash_3words().
> Just create a simple application which does
> jhash_3words(a, b, rand(), init) and jhash_2words(a, b, rand()) and see
> results.

    What exactly am I supposed to see in these results? Because whatever it 
is, it's not there. Feel free to provide a link to your data and a histogram 
that shows what you find of interest though, and I'll be happy to look at 
it.

    -n
 


