From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 13:09:44 -0800
Message-ID: <CALCETrUgOpcNO6L3eabAr3P8p86PGYT7BfCt9mcNTu6TNfP7Dw@mail.gmail.com>
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
>
>> I can see this working if you have a special type of skb that
>> indicates that the data might be concurrently written and have all the
>> normal skb APIs (including, especially, anything that clones it) make
>> a copy first.
>
> Support for cloned skbs is required for TCP, both at tcp_transmit_skb
> and segmentation offload. Patch 4 especially adds reference counting
> of shared pages across clones and other sk_buff operations like
> pskb_expand_head. This still allows for deep copy (skb_copy_ubufs)
> on clones in specific datapaths like the above.

Does this mean that a user program that does a zerocopy send can cause
a retransmitted segment to contain different data than the original
segment?  If so, is that okay?
