From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Subject: Re: RFC: Established connections hash function
Date: Thu, 22 Mar 2007 10:32:44 -0700
Message-ID: <391F64D0A7C5463CA2D70362E4B3E7EC@XEON>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <20070322155227.GA18557@2ka.mipt.ru>
Reply-To: nikb@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="koi8-r";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:1102 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934146AbXCVRdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 13:33:08 -0400
Received: from XEON by webmaster.com
	(Cipher TLSv1:RC4-MD5:128) (MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50001457296.msg
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 10:33:03 -0800
In-Reply-To: <20070322155227.GA18557@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, March 22, 2007 at 8:52 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> 
wrote:

> It seems you do not know a history...

    I know a lot about history. I may not know the specific history you had 
in mind though.

    I do see now that this has been brought up before. Before posting, I did 
search the archives, but obviously not closely enough. I blame it on the 
early morning hour.


> It is the fastest and actually the best hash for that workloads where it
> is used, but unfortunately it is too simple for attacker to predict end
> result.

    Yes, the distribution of the vanilla function is decent, and yes it's 
very fast. But all that won't help you when chains start having tens of 
thousands of items, and you have to iterate through them constantly. But I 
guess that if it makes you feel better, you can call that "unfortunate."


>> unsigned int inet_ehashfn(const __be32 laddr, const __u16 lport,
>>                          const __be32 faddr, const __be16 fport)
>> {
>>    return jhash_3words((__force __u32)faddr, (__force __u32)laddr,
>>                        (((__force __u32)fport) << 16) + lport,
>>                        inet_ehash_rnd);
>> }
>
> And this is utterly broken. For more details please read netdev@
> archives and trivial analysis of jhash_3words().

    Utterly broken? Nonsense. I have tested the actual function I proposed 
(sans the __force and __u32 stuff, which weren't necessary in my test 
program), against real data, collected from various servers in real-time. It 
has consistently achieved lower average chain lengths than the vanilla 
function and demonstrated no artifacting, and that's trivial to verify.

    The only analysis I could find was this 
http://tservice.net.ru/~s0mbre/blog/2006/05/14#2006_05_14, which uses 
jhash_2words, and not jhash_3words, and which naively attempts to take the 
output of jhash_2words, and to perform the same mixing trick that the 
vanilla inet_ehashfn does and uses artificially generated data sets.

    But please, feel free to point out any other _unfavorable_ analyses of 
jhash_2words or jhash_3words that I may have missed.


> We can use jhash_2words(laddr, faddr, portpair^inet_ehash_rnd) though.

    Please explain to me how jhash_2words solves the issue that you claim 
jhash_3words has, when they both use the same underlying bit-mixer?

    -n 


