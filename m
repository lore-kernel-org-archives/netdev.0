From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 17:50:07 -0800
Message-ID: <CALx6S35UxT6UhVhJZmVmTx867p7G6GbKWS217Q_K0cHc1V8sUQ@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
 <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
 <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
 <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
 <1488318476.9415.270.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrVQj1AEsLEGGkWW1zApGz6_x2rDmE0wz4ft+O5h07f_Ug@mail.gmail.com>
 <1488321643.9415.272.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrXqO=ptrcHs0kLLfqA2nskGck4ntAnsaJdcjmqNuoVfNQ@mail.gmail.com>
 <1488324131.9415.278.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S357ssnbEu7CMrczEjiX25QYBJh3WG=w8KuAoxGQS4aKLA@mail.gmail.com> <CAF=yD-L76wJhxVgG6CDYmQFfWYkUyK7QCWt_Jue_Tdh4hHVLgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Andy Lutomirski <luto@amacapital.net>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Linux API <linux-api@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33431 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdCAB5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 20:57:02 -0500
Received: by mail-qk0-f175.google.com with SMTP id n127so48553192qkf.0
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 17:57:02 -0800 (PST)
In-Reply-To: <CAF=yD-L76wJhxVgG6CDYmQFfWYkUyK7QCWt_Jue_Tdh4hHVLgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 4:58 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Tue, Feb 28, 2017 at 7:28 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Tue, Feb 28, 2017 at 3:22 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Tue, 2017-02-28 at 14:52 -0800, Andy Lutomirski wrote:
>>>
>>>> The user pages are a gift to the kernel.  The application  may  not
>>>> modify this memory ever, otherwise the page cache and on-disk data may
>>>> differ.
>>>>
>>>> This is just not okay IMO.
>>>
>>> TCP works just fine in this case.
>>>
>>> TX checksum will be computed by the NIC after/while data is copied.
>>>
>>> If really the application changes the data, that will not cause any
>>> problems, other than user side consistency.
>>>
>>> This is why we require a copy (for all buffers that came from zero-copy)
>>> if network stack hits a device that can not offload TX checksum.
>>>
>>> Even pwrite() does not guarantee consistency if multiple threads are
>>> using it on overlapping regions.
>>>
>> The Mellanox team working on TLS offload pointed out to us that if
>> data is changed for a retransmit then it becomes trivial for someone
>> snooping to break the encryption. Sounds pretty scary and it would be
>> a shame if we couldn't use zero-copy in that use case :-( Hopefully we
>> can find a solution...
>>
>
> This requires collusion by the process initiating the zerocopy send
> to help the entity snooping the link. That could be an attack on admin
> configured tunnels, but user-directed encryption offload like AF_TLS
> can still use zerocopy.

Yes, but we can't trust the user to always understand or correctly
implement the semantic nuances when security is involved. If we can't
provide a  robust API then the only recourse is to not allow zero copy
in that case. We could suggest COW to solve all problems, but I think
we know where the conversation will go ;-)

Tom
