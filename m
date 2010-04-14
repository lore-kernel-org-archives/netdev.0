From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] fix potential wild pointer when NIC is dying
Date: Wed, 14 Apr 2010 15:25:01 +0800
Message-ID: <u2r412e6f7f1004140025i51e533c9t7402bc751dd925c2@mail.gmail.com>
References: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
	<1271223212.16881.598.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:55847 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab0DNHZW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 03:25:22 -0400
Received: by ywh36 with SMTP id 36so3554833ywh.4
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 00:25:21 -0700 (PDT)
In-Reply-To: <1271223212.16881.598.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 14, 2010 at 1:33 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 14 avril 2010 =C3=A0 20:18 +0800, Changli Gao a =C3=A9cri=
t :
>
> I dont see how the problem can happens, and how RPS is involved.
>
> Did you got a single panic, could you provide us a stack trace ?
>
> Maybe are you referring to NAPI ?
>
> NAPI process packets delivered by NIC, and through RPS deliver it to =
a
> (possibly) remote CPU queue.
>
> But at device dismantle time, we should stop NAPI on this device and
> packet delivery machinery. RPS being on or not, NAPI wont deliver new
> packets. The fact that NAPI can be throtled doesnt change the napi
> instance being disabled at this point. No more packet will be deliver=
ed
> (RPS or not)
>
> Only after this point we call flush_backlog() to make sure we dont ha=
ve
> any queued packet in each cpu input_pkt_queue pointing to the device =
we
> dismantle.
>
> RPS doesnt change this at all.
>
> Hmm ???
>

Thanks, I got it.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
