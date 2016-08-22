From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v3 net-next] l2tp: Refactor the codes with existing macros
 instead of literal number
Date: Mon, 22 Aug 2016 18:29:31 +0800
Message-ID: <CA+6hz4rL4HDioopQFWg1RgVSQ7=0_fOZpof5hRebLFqovD1Asg@mail.gmail.com>
References: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
 <9423c2ce-fb0c-818c-1b27-d45668f4a015@redfish-solutions.com> <20160822094813.bpch2uzyhtbnrqmx@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Philp Prindeville <philipp@redfish-solutions.com>,
        Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>,
        paulus@samba.org, "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:33755 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751602AbcHVK3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:29:33 -0400
Received: by mail-ua0-f194.google.com with SMTP id u13so10408791uau.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 03:29:32 -0700 (PDT)
In-Reply-To: <20160822094813.bpch2uzyhtbnrqmx@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inline

On Mon, Aug 22, 2016 at 5:48 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Sun, Aug 21, 2016 at 04:36:52PM -0600, Philp Prindeville wrote:
>> Inline
>>
>>
>> On 08/20/2016 09:52 AM, fgao@48lvckh6395k16k5.yundunddos.com wrote:
>> > From: Gao Feng <fgao@ikuai8.com>
>> >
>> > Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
>> > 0x03, and 2 separately.
>> >
>> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> > ---
>> >   v3: Modify the subject;
>> >   v2: Only replace the literal number with macros according to Guillaume's advice
>> >   v1: Inital patch
>> >
>> >   net/l2tp/l2tp_ppp.c | 8 ++++----
>> >   1 file changed, 4 insertions(+), 4 deletions(-)
>> >
>> > diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
>> > index d9560aa..65e2fd6 100644
>> > --- a/net/l2tp/l2tp_ppp.c
>> > +++ b/net/l2tp/l2tp_ppp.c
>> > @@ -177,7 +177,7 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
>> >     if (!pskb_may_pull(skb, 2))
>> >             return 1;
>> > -   if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
>> > +   if ((skb->data[0] == PPP_ALLSTATIONS) && (skb->data[1] == PPP_UI))
>>
>> This should have used PPP_ADDRESS() and PPP_CONTROL() here.
>>
> Then please justify how would that make the code more readable.
> We're not trying to interpret a known valid PPP header here.
>
>> >             skb_pull(skb, 2);
>>
>> This magic number should go away.
>>
> Again, this is *not* a magic number. We've explicitely accessed the
> first _two_ header bytes and want to skip them.
> pskb_may_pull(2), ->data[0], ->data[1] and skb_pull(2) all go together.
>
> There's even a nice comment telling you what is done and why:
>         /* Skip PPP header, if present.  In testing, Microsoft L2TP clients
>          * don't send the PPP header (PPP header compression enabled), but
>          * other clients can include the header. So we cope with both cases
>          * here. The PPP header is always FF03 when using L2TP.
>          *
>          * Note that skb->data[] isn't dereferenced from a u16 ptr here since
>          * the field may be unaligned.
>          */
> Apart from the unprecise "PPP header" term, which should be read as
> "address and control fields", things should be quite clear.

If remove the static ppph, may be more clear. Because it will cause
person think about the ppp header.

Regards
Feng

>
>> > @@ -282,7 +282,7 @@ static void pppol2tp_session_sock_put(struct l2tp_session *session)
>> >   static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
>> >                         size_t total_len)
>> >   {
>> > -   static const unsigned char ppph[2] = { 0xff, 0x03 };
>> > +   static const unsigned char ppph[2] = {PPP_ALLSTATIONS, PPP_UI};
>>
>> PPP has a 4-byte header.  Where's the protocol value?
>>
> No, PPP header (whatever you include in it) is of variable length. And
> the protocol has already been set by the PPP layer anyway.
> We're in L2TP here.
