From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [GIT] Networking
Date: Wed, 29 Apr 2015 19:53:49 +0200
Message-ID: <CAK1hOcPTStgJ+PF8Mq02tDz2nvSX9U74+gBRoGVYXCDN2TnfJQ@mail.gmail.com>
References: <20150401.154847.612566794393812348.davem@davemloft.net>
 <CAK1hOcOd=dLUyxJy1mEj2=Hy-zOqDp2KJ8or+1Zrsk+BvNn5oQ@mail.gmail.com> <5540F605.2040907@modio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Don Howard <dhoward@redhat.com>
To: "D.S. Ljungmark" <ljungmark@modio.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:35779 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbD2RyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 13:54:10 -0400
In-Reply-To: <5540F605.2040907@modio.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 5:17 PM, D.S. Ljungmark <ljungmark@modio.se> wrote:
>
> On 29/04/15 16:51, Denys Vlasenko wrote:
>> # for f in /proc/sys/net/ipv6/conf/*/hop_limit; do echo -n $f:; cat $f; done
>> /proc/sys/net/ipv6/conf/all/hop_limit:64
>> /proc/sys/net/ipv6/conf/default/hop_limit:64
>> /proc/sys/net/ipv6/conf/enp0s25/hop_limit:1  <=== THIS
>> /proc/sys/net/ipv6/conf/lo/hop_limit:64
>> /proc/sys/net/ipv6/conf/wlp3s0/hop_limit:64
>>
>> As you see, the interface which received RAs still lowered
>> its hop_limit to 1. I take it means that the bug is still present
>> (right? I'm not a network guy...).
>
> It might not be present in the _kernel_. Do you run NetworkManager on
> your system? If so, see below.

Yes. "killall -STOP  NetworkManager" and now I see that bug is fixed.

Sorry for the false alarm.

(If anyone would want to reproduce this, NB:
be sure to also enable accept_ra* sysctls,
otherwise kernel will ignore RAs and bug wouldn't be reproduced
on previous kernels too).
