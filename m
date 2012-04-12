From: Eldad Zack <eldad@fogrefinery.com>
Subject: Re: [PATCH] net/ipv6/exthdrs.c et al: Optional strict PadN option checking
Date: Thu, 12 Apr 2012 23:31:47 +0200
Message-ID: <CABe5r8JJPuhq3r=JnfLA=_U46-SFmK+g3XqC3MaRdLxwVXx9Qw@mail.gmail.com>
References: <CABe5r8Kygjg0O21Y5z-F=RRQCqT7ReNya+EohAJU1jauaK536Q@mail.gmail.com>
	<1333811774-3219-1-git-send-email-eldad@fogrefinery.com>
	<20120412.160040.1086391259430365718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54397 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604Ab2DLVbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 17:31:48 -0400
Received: by iagz16 with SMTP id z16so3324461iag.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 14:31:47 -0700 (PDT)
In-Reply-To: <20120412.160040.1086391259430365718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 April 2012 22:00, David Miller <davem@davemloft.net> wrote:
>> Added strict checking of PadN. PadN can be used to increase header
>> size and thus push the protocol header into the 2nd fragment.
>>
>> PadN is used to align the options within the Hop-by-Hop or
>> Destination Options header to 64-bit boundaries. The maximum valid
>> size is thus 7 bytes.
>> RFC 4942 recommends to actively check the "payload" itself and
>> ensure that it contains only zeroes.
> I think you should do away with the sysctl and always perform these
> checks.
>
> At the very leat, the optlen > 7 check should always be performed.
> And frankly the pad byte being zero check makes sense to do all the
> time as far as I can tell too.

That's the way I see it, as was my initial intent. Then I got
concerned with the possibility that a communication with
slightly-broken stack implementation (e.g., unsanitized buffers) would
fail without the user being able to control it at runtime.
Do you consider this a non-issue?

If not, please apply the (soon to be sent) patch.

Thanks,
Eldad
