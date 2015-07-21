From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Tue, 21 Jul 2015 12:51:04 -0400
Message-ID: <CA+FuTSctXr=2eC_-e793hvAPu=XyEhLeLoowH95tbOBx8CGj7g@mail.gmail.com>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
 <CA+FuTScr0o0ZmwWxVP4FZoQosRRiQG6+MDvCahMCWmjLkg+33g@mail.gmail.com> <CAFBinCB4xOBzxwkEQYrpi1q7Xm4_-hpj2jUE2r-fQ5f2grjZ=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, johann.baudy@gnu-log.net
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34346 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbGUQvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 12:51:35 -0400
Received: by ykax123 with SMTP id x123so171161969yka.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 09:51:34 -0700 (PDT)
In-Reply-To: <CAFBinCB4xOBzxwkEQYrpi1q7Xm4_-hpj2jUE2r-fQ5f2grjZ=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2015 at 12:38 PM, Martin Blumenstingl
<martin.blumenstingl@googlemail.com> wrote:
> Hi Willem,
>
> On Tue, Jul 21, 2015 at 6:28 PM, Willem de Bruijn <willemb@google.com> wrote:
>> Interesting. 9c7077622dd9 only extended the check from tpacket_snd to
>> packet_snd to make the two paths equivalent. The existing check had the
>> ominous statement
>>
>>     /* net device doesn't like empty head */
> OK, I guess it's best to find out what the purpose of this comment is.
>
>> so allowing a header-only packet while correct in your case may not be
>> safe in some edge cases (specific device drivers?).
> I'm wondering how a good fix would look like (I can think of a few
> things, like renaming hard_header_len to something min_packet_size)?
> I am open for suggestions since I have zero knowledge about the inner
> workings of the packet framework.

I don't see a simple way of verifying the safety of allowing packets
without data short of a code audit, which would be huge, especially
when taking device driver logic into account. Perhaps someone
remembers why that statement was added and what edge case(s)
it refers to. I'm afraid that I don't. It was added in 69e3c75f4d54. I
added the author to this thread.

>> This was also discussed previously
>>
>>   http://www.spinics.net/lists/netdev/msg309677.html
>>
>> In any case, I don't think that reverting the patch and restoring the old
>> inconsistent state is a fix.
> I totally agree with you that it's a bad fix if this means that we
> could break other drivers.
> My primary goal was to fix PPPoE connections - I guess I should have
> simply added "RFC" to the subject.
>
>
> Regards,
> Martin
