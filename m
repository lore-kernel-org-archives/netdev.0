From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 7 May 2008 11:54:01 -0700
Message-ID: <d1c2719f0805071154t20004e9drecd3d9b7b9b3470c@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <20080425.000547.152086801.davem@davemloft.net>
	 <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
	 <20080506.212829.213490532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:11895 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756773AbYEGSyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 14:54:12 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m47Is4wB001886
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 19:54:05 +0100
Received: from wx-out-0506.google.com (wxdh29.prod.google.com [10.70.134.29])
	by zps36.corp.google.com with ESMTP id m47Is1Dq014426
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 11:54:03 -0700
Received: by wx-out-0506.google.com with SMTP id h29so441964wxd.11
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 11:54:01 -0700 (PDT)
In-Reply-To: <20080506.212829.213490532.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2008 at 9:28 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
>
> Date: Tue, 6 May 2008 20:57:46 -0700
>
>
> > It may be getting a copy (e.g., when GSO is on?) hence losing all
>  > its connection to the original tp and any chance to have the pkt
>  > properly accounted for as host_infligh by TCP. The skb may also be
>  > cloned more than once (e.g., due to tcpdump)...
>
>  It only gets a copy if the SKB is already cloned and that clone is
>  alive somewhere (f.e. stuck in the device, a rare occurance by
>  the time we retransmit).

This is one of many things about skb that I still don't completely understand.
Why in tcp_transmit_skb() we'll have to pskb_copy() if skb_cloned()?
Can't we clone a skb mulitple times? Is it due to some special optimization
from skb->fclone stuff... that imposes this restriction?

>
>  It is a clone %99.999999 of the time.

When I turned on GSO but not TSO, I believe it's a copy %99.999999 of
the time. (I must confess I don't understand GSO code yet. I temporarily
ran out of stream after studying bunch of other code.)

Jerry

>
