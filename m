From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 13:06:49 -0800
Message-ID: <CALCETrXogADnqymxaoqt=F3rDMpOYQ0xy7audng=t-Rx1bxqbw@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
 <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com> <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 12:43 PM, Willem de Bruijn
<willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Feb 28, 2017 at 2:46 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> On Mon, Feb 27, 2017 at 10:57 AM, Michael Kerrisk
>> <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> [CC += linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org]
>>>
>>> Hi Willem
>>>
>>
>>>> On a send call with MSG_ZEROCOPY, the kernel pins the user pages and
>>>> creates skbuff fragments directly from these pages. On tx completion,
>>>> it notifies the socket owner that it is safe to modify memory by
>>>> queuing a completion notification onto the socket error queue.
>>
>> What happens if the user writes to the pages while it's not safe?
>>
>> How about if you're writing to an interface or a route that has crypto
>> involved and a malicious user can make the data change in the middle
>> of a crypto operation, thus perhaps leaking the entire key?  (I
>> wouldn't be at all surprised if a lot of provably secure AEAD
>> constructions are entirely compromised if an attacker can get the
>> ciphertext and tag computed from a message that changed during the
>> computation.
>
> Operations that read or write payload, such as this crypto example,
> but also ebpf in tc or iptables, for instance, demand a deep copy using
> skb_copy_ubufs before the operation.
>
> This blacklist approach requires caution, but these paths should be
> few and countable. It is not possible to predict at the socket layer
> whether a packet will encounter any such operation, so white-listing
> a subset of end-to-end paths is not practical.

How about hardware that malfunctions if the packet changes out from
under it?  A whitelist seems quite a bit safer.

--Andy
