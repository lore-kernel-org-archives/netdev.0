From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Wed, 14 Aug 2013 08:40:46 +0200
Message-ID: <AFA62E3B-313C-4ECD-BA28-3543635136EE@inf-net.nl>
References: <2A0809D4-EBF1-4646-9564-2B7F54956B41@inf-net.nl> <20130810120348.GP14001@order.stressinduktion.org> <190D21D2-F86E-46D2-93E8-3050F57FE622@inf-net.nl> <20130813.011550.791636011692333018.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>,
	Lorenzo Colitti <lorenzo@google.com>,
	Dave Taht <dave.taht@gmail.com>, Ole Troan <ot@cisco.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:53623 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab3HNGkx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 02:40:53 -0400
Received: by mail-ee0-f48.google.com with SMTP id l10so4577295eei.21
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 23:40:51 -0700 (PDT)
In-Reply-To: <20130813.011550.791636011692333018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for status update.

For the record: yes, source address dependent routing has my interest. I'm not feeling lonely at all.
There is a draft for this: http://tools.ietf.org/html/draft-troan-homenet-sadr-00
Most (if not all) Linux implementations use the IP RULES hack to implement.
Lorenzo Colitti heard from David Lamparter the: "Linux IPv6 source routing code (the mythical CONFIG_IPV6_SUBTREES?) to work on 3.8": http://www.ietf.org/mail-archive/web/homenet/current/msg02964.html
Few follow-ups were posted, also by David: http://www.ietf.org/mail-archive/web/homenet/current/msg02966.html
This triggered me using that code. But it was broken !!! Discussed this with Matthieu Boutier and Juliusz Chroboczek, they faced same problem and therefore also used the IP RULES hack in their implementation. http://www.ietf.org/id/draft-boutier-homenet-source-specific-routing-00.txt
So I reported the bug. David Lamparter worked on a fix, Hannes completed it. So far so good.
Also, Dave Taht reported the issue and made us aware on lots of patches making the IP RULES hack less painful. 
http://www.ietf.org/mail-archive/web/homenet/current/msg03019.html

FYI, I tested the patch from Hannes on current Ubuntu with 3.8.0.28. Due to other "fixes" this kernel is broken. Bad to make this available to Ubuntu users. So yes, I understand fixes must be tested before getting into stable. Therefore I double-checked this IPV6_SUBTREES fix. 

Now we have to decide what to do. Wait to get the fix in the wild for some time and continue with the IP RULES hack, implemented in today's experimental SADR implementations. Or start using the more elegant IPV6_SUBTREES method. I vote for the latter. I cannot see a reason for delay. Current situation is bad enough.

What can I do to make progress? Spam Linus?

Thanks, Teco


Op 13 aug. 2013, om 10:15 heeft David Miller <davem@davemloft.net> het volgende geschreven:

> From: Teco Boot <teco@inf-net.nl>
> Date: Tue, 13 Aug 2013 10:02:08 +0200
> 
>> It is an important element in my work for v6 multi-homed networks
>> (IETF Homenet WG).
> 
> You are one person.  -stable inclusion is decided based how important the
> fix is to everyone in both good (fixes a bug) and bad (might cause a
> regression) terms.
> 
> So "this is important for my work" is never a good reason for a patch
> to be included into -stable.
> 
> To convince us, you're going to have to present an argument that
> exists outside the very limited scope of your own self-interests.
> And "other people might/will use my important work in the future"
> is not sufficient either.
> 
> Thanks.
> 
