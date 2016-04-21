From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH v2 net-next 2/7] tcp: Merge tx_flags/tskey/txstamp_ack
 in tcp_collapse_retrans
Date: Thu, 21 Apr 2016 16:25:55 -0400
Message-ID: <CAF=yD-K-7h36Kw1dirPVhsbsv63dJSbLoefUiNzh_UvaK7_UXg@mail.gmail.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-3-git-send-email-kafai@fb.com> <CACSApvY5ZdyUO1i2O0KPGJM5meWHFv3hdi9Ew89CH--jFV4yOw@mail.gmail.com>
 <20160419172837.GA37697@kafai-mba.local> <CANn89iJ=Kk3oNbkJ4pOg6bnvJFOUjJa6SSem1jb=BOkR0FF=3g@mail.gmail.com>
 <20160419181644.GA40600@kafai-mba.local> <CACSApvbzAtCTnom+xyQmaG=ATwncMnvLLDdxqCAYWG7rgYbBmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34551 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbcDUU0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 16:26:36 -0400
Received: by mail-lf0-f68.google.com with SMTP id e190so8496205lfe.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 13:26:35 -0700 (PDT)
In-Reply-To: <CACSApvbzAtCTnom+xyQmaG=ATwncMnvLLDdxqCAYWG7rgYbBmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 2:24 PM, Soheil Hassas Yeganeh
<soheil@google.com> wrote:
> On Tue, Apr 19, 2016 at 2:18 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>> On Tue, Apr 19, 2016 at 10:35:52AM -0700, Eric Dumazet wrote:
>>> On Tue, Apr 19, 2016 at 10:28 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>>>
>>> > A bit off topic, I feel like the SKBTX_ACK_TSTAMP and txstamp_ack are sort
>>> > of redundant but I have not look into the details yet, so not completely
>>> > sure.  It wwould be a separate cleanup patch if it is the case.

Yes, with the introduction of txstamp_ack, SKBTX_ACK_TSTAMP is completely
redundant.

>>>
>>> Please read 6b084928baac562ed61866f540a96120e9c9ddb7 changelog ;)
>>>
>>> A cache line miss avoidance is critical
>> I looked at the patch but I probably am missing something :(
>> Is checking txstamp_ack alone enough and SKBTX_ACK_TSTAMP is not needed
>> since they are always set together?
>
> That's right, the check on "(shinfo->tx_flags & SKBTX_ACK_TSTAMP)" in
> tcp_ack_tstamp() is redundant and I had a patch prepared to remove it.

You can even remove the flag completely and

-               tcb->txstamp_ack = !!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
+               if (tsflags & SOF_TIMESTAMPING_TX_ACK)
+                       tcb->txstamp_ack = 1;

> But I thought it's better to wait for
> https://patchwork.ozlabs.org/patch/611938/ to be merged first.
>
> Feel free to remove it in your patches, if you'd prefer that.
