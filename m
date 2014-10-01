From: Tom Herbert <therbert@google.com>
Subject: Re: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 22:15:56 -0700
Message-ID: <CA+mtBx8mt5qez5X5tPF_3S+0p2svmLScmxBvXziBYT9XTJ+w0w@mail.gmail.com>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	<CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
	<B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
	<1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<B5657A6538887040AD3A81F1008BEC63B4159B@avmb3.qlogic.org>
	<B5657A6538887040AD3A81F1008BEC63B415CB@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:64999 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaJAFP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 01:15:57 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so364429igd.4
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 22:15:56 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B415CB@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 1:32 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>>> IPv4 header is supposed to have a 0 checksum ;)
>>>
>
>>Oops. Sorry, you're right.
>
>>But this is a bit strange.
>
>>I mean, if I go back to the IP-GRE case [with GRE checksum], the IP
>>csum negates the rest of the IP header and the GRE csum negates
>>everything else [GRE header, inner headers and payload].
>>So the mechanism might work as-is, but all the driver has to
>>do in order to claim that an IP-gre packet with checksum option is
>>CHECKSUM_COMPLETE is to write 0xffffffff on the skb's csum field.
>
> Or looking back on the IPv4/TCP scenario, what exactly is the csum
> now protecting?
> Assume the HW passes the one's complement sum of the entire data,
> IP header and onward to driver, which sets it in SKB->csum and marks
> the SKB as CHECKSUM_COMPLETE.
> In practice, SKB->csum should now equal to the one's complement of
> the TCP pseudo header; But other than the length of data in the TCP
> header and payload that pseudo-header doesn't include any
> information about the payload itself.

But it does, as you pointed out the checksum calculation was performed
over the whole payload. The fact that the computed checksum equals the
one's complement of pseudo header is the indication that the checksum
is valid. If there were a bit corruption, the computed value would be
different (summing in pseudo header checksum would result in non-zero
value).

> If we're willing to accept the payload [and the correctness of the
> header while we're at it] based solely on this, what guarantee do we
> have that the TCP checksum is actually correct?
> Seems like the only thing we've guaranteed is that nothing switched in
> IP header since packet passed the HW - but we've already got that
> covered by the IPv4 layer.
>
> [I assume I'm missing something elementary here. Same as before ;-)]

I think your assumption is correct ;-) You might want to take a look
at some of the RFCs that describe checksum verification with pseudo
header.
