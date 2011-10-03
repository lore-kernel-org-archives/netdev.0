From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: x25: remote-triggerable heap overflow in call user data processing
Date: Mon, 3 Oct 2011 17:51:53 +1100
Message-ID: <CADo0ohj-CJs9qCz9=LNCrGwduREVK54qUfTqTM+hXDWMATT9Zg@mail.gmail.com>
References: <CA+nUz_K-mWFbFbSGKDFDGUufQmDA9+qW-0=1BDJ9QGe2Dxi-3w@mail.gmail.com>
	<1317620731.3802.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: matt d <mattjd@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41876 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab1JCGvy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 02:51:54 -0400
Received: by vws1 with SMTP id 1so2504451vws.19
        for <netdev@vger.kernel.org>; Sun, 02 Oct 2011 23:51:54 -0700 (PDT)
In-Reply-To: <1317620731.3802.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x25_in.c looks straightforward.
with af_x25.c we might want to move the incoming call user data check
before the call accept block above.
Otherwise it could send call accept/call clear right next to each
other and it might get bad state

On Mon, Oct 3, 2011 at 4:45 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 03 octobre 2011 =E0 16:23 +1300, matt d a =E9crit :
>> Refer to the x25 packet layer's handling of incoming call user data,
>> namely at these two locations, in x25_rx_call_request and
>> x25_state1_machine:
>> https://github.com/mirrors/linux/blob/master/net/x25/af_x25.c#L1039
>> https://github.com/mirrors/linux/blob/master/net/x25/x25_in.c#L126
>>
>> Call user data from an incoming message is copied into
>> (make)x25->calluserdata.cuddata buffers, which are 128 bytes long.
>> However, the length copied is based on the remaining message length,
>> and is not limited to the output buffer size. This allows a remote
>> attacker to overflow data onto the heap.
>>
>> There is an appropriate constant defined for the length, but it
>> seemingly isn't used there:
>> https://github.com/mirrors/linux/blob/master/include/net/x25.h#L104
>>
>> It seems this issue was noticed some time ago:
>> http://www.spinics.net/lists/linux-x25/msg00043.html
>> http://patchwork.ozlabs.org/patch/23917/
>> ...however nothing was done about the bigger problem.
>>
>> I have written a simple exploit for this vulnerability if it needs t=
o
>> be posted, however I think the problem is pretty straightforward to
>> see as-is.
>
> Please send a patch, it seems you have everything done to do it
> properly ;)
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
