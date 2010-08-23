From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] bridge: netfilter: fix a memory leak
Date: Mon, 23 Aug 2010 12:40:28 +0800
Message-ID: <AANLkTimCZKGvp9Mnr5Afwo1gRVcLPtYn9Z5=c9NYjm6y@mail.gmail.com>
References: <1282280596-18992-1-git-send-email-xiaosuo@gmail.com> <20100822.213632.191389158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55687 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523Ab0HWEkt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:40:49 -0400
Received: by wwd20 with SMTP id 20so665408wwd.1
        for <netdev@vger.kernel.org>; Sun, 22 Aug 2010 21:40:48 -0700 (PDT)
In-Reply-To: <20100822.213632.191389158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 12:36 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Fri, 20 Aug 2010 13:03:16 +0800
>
>> nf_bridge_alloc() always reset the skb->nf_bridge, so we should alwa=
ys
>> put the old one. skb->nf_bridge->use is initialized in nf_bridge_all=
oc(),
>> so we don't need to initialize it again.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> We just memcpy()'d 'nf_bridge' to 'tmp', that why the ->use count is
> going to be something other than '1'. =A0It now has the ->use count t=
hat
> 'nf_bridge' did.
>
> And that is why we must explicitly do atomic_set() on 'tmp'.
>

Oops, thanks. I'll post a update.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
