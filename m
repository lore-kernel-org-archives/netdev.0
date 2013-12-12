From: Jacob Appelbaum <jacob@appelbaum.net>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Thu, 12 Dec 2013 12:23:54 +0000
Message-ID: <52A9AADA.5090603@appelbaum.net>
References: <52A75EF8.3010308@in.tum.de> <20131211.150137.368953964178408437.davem@davemloft.net> <52A8C8B4.4060109@in.tum.de> <20131211122637.75b09074@nehalam.linuxnetplumber.net> <87bo0nulkt.fsf@tassilo.jf.intel.com> <52A8ECF5.3070604@in.tum.de> <20131212012317.GL21717@two.firstfloor.org> <52A98DBF.4090702@appelbaum.net> <52A9A17F.6050505@in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org
To: Christian Grothoff <grothoff@in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:48800 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507Ab3LLM2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 07:28:08 -0500
Received: by mail-we0-f182.google.com with SMTP id q59so352863wes.13
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 04:28:07 -0800 (PST)
In-Reply-To: <52A9A17F.6050505@in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Grothoff:
> On 12/12/2013 11:19 AM, Jacob Appelbaum wrote:
>> I think that generally, I would prefer if the code didn't use MD5 but
>> otherwise, I don't see any real risk of adding an exploitable hole. It
>> seems silly to disable it by default though - ideally, I'd like a sysctl
>> to ensure that Tor could use this without making the user recompile
>> their kernel. That is more of a pain than running a userspace helper, I
>> think.
>>
>> All the best,
>> Jacob
> 
> Given that the output is truncated to 32 bits and that performance (SYN
> flood) is also a concern, AND that the original TCP SQN generation is
> also MD5-based (and we want to look the same), what disadvantage do you
> see over MD5?  Given the truncation to 32 bits, I don't think a stronger
> hash would do anything for us.

If we believe that MD5 is not secure, we should not use it. That others
use it is not a strong reason to use it. Everyone should stop using MD5
- especially truncated MD5. :)

> 
> As for it being disabled by default, we did this with respect to
> kernel submission guidelines which we understood said that features
> should _initially_ always be submitted with disabled-by-default
> (presumably so that until they have stabilized, nobody is harmed
> unless they explicitly activate the code).
> 

I think that is a fine reason at submission time but this should not be
the default state for very long.

> I don't see the point in having a sysctl, as applications have to
> explicitly request it anyway.

To have it supported and to have it enabled in the kernel are not
exactly the same thing. It would be nice if it was available to everyone
by default (likely with some CAP) and to enable it on a systemwide
basis, one could simply flip a sysctl. One also needs to use it in an
application, obviously.

All the best,
Jacob
