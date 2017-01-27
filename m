From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Fri, 27 Jan 2017 10:28:16 -0500
Message-ID: <CAF=yD-+LS6g572Uo5oErq7uazxxPwXXo0w2p4zcHDbXxkuah6Q@mail.gmail.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
 <20170126213742.GE29475@oracle.com> <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
 <20170127020836.GH29475@oracle.com> <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
 <20170127151119.GB25829@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:34708 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755060AbdA0P32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:29:28 -0500
Received: by mail-wj0-f196.google.com with SMTP id ip10so6211615wjb.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 07:28:57 -0800 (PST)
In-Reply-To: <20170127151119.GB25829@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> " The AX.25 device level drivers are simply written to be robust if
>   thrown partial frames.
>    :
>   The other thing that concerns me about this added logic in general is
>   that you are also breaking test tools that want to deliberately send
>   corrupt frames to certain classes of interface."
>
> But how does the driver (even a robust one!) compute the L2 dst/src if the
> application has not even passed down the minimum (which is 21 for ax25?)

Perhaps the goal is to test that the driver gracefully handles such
packets. I can only speculate.

> Would it make sense to only do the CAP_SYS_RAWIO branch if the
> driver declares itself to have variable length L2 headers, via, e.g.,
> some priv flag?

At the time, the comments were not specific to AX25. Again, we should
probably put that bypass behind a flag, enabling validating in the common case.

> BTW the http://comments.gmane.org/gmane.linux.network/401064 referred
> to in commit 2793a23 is not accessible any more, not sure if its contents
> were the same as the link you just shared.

It is. I looked it up in my email archive. Too bad that that seems to
be the only way.
