From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 19:58:39 -0500
Message-ID: <CAF=yD-L76wJhxVgG6CDYmQFfWYkUyK7QCWt_Jue_Tdh4hHVLgA@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
 <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
 <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
 <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
 <1488318476.9415.270.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrVQj1AEsLEGGkWW1zApGz6_x2rDmE0wz4ft+O5h07f_Ug@mail.gmail.com>
 <1488321643.9415.272.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrXqO=ptrcHs0kLLfqA2nskGck4ntAnsaJdcjmqNuoVfNQ@mail.gmail.com>
 <1488324131.9415.278.camel@edumazet-glaptop3.roam.corp.google.com> <CALx6S357ssnbEu7CMrczEjiX25QYBJh3WG=w8KuAoxGQS4aKLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALx6S357ssnbEu7CMrczEjiX25QYBJh3WG=w8KuAoxGQS4aKLA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 7:28 PM, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
> On Tue, Feb 28, 2017 at 3:22 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Tue, 2017-02-28 at 14:52 -0800, Andy Lutomirski wrote:
>>
>>> The user pages are a gift to the kernel.  The application  may  not
>>> modify this memory ever, otherwise the page cache and on-disk data may
>>> differ.
>>>
>>> This is just not okay IMO.
>>
>> TCP works just fine in this case.
>>
>> TX checksum will be computed by the NIC after/while data is copied.
>>
>> If really the application changes the data, that will not cause any
>> problems, other than user side consistency.
>>
>> This is why we require a copy (for all buffers that came from zero-copy)
>> if network stack hits a device that can not offload TX checksum.
>>
>> Even pwrite() does not guarantee consistency if multiple threads are
>> using it on overlapping regions.
>>
> The Mellanox team working on TLS offload pointed out to us that if
> data is changed for a retransmit then it becomes trivial for someone
> snooping to break the encryption. Sounds pretty scary and it would be
> a shame if we couldn't use zero-copy in that use case :-( Hopefully we
> can find a solution...
>

This requires collusion by the process initiating the zerocopy send
to help the entity snooping the link. That could be an attack on admin
configured tunnels, but user-directed encryption offload like AF_TLS
can still use zerocopy.
