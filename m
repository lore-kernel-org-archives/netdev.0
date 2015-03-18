From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next 3/4] ipv4: Use probe_size to check write queue
 data length
Date: Wed, 18 Mar 2015 08:41:58 -0400
Message-ID: <CABrhC0kBjm+qRRpeLugR2Dyc=XXrC5CWxW8_LecbPbbLpe5bkQ@mail.gmail.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com>
	<1425978986-8512-4-git-send-email-fan.du@intel.com>
	<CABrhC0=+c1XpVZZpRyhrFJmUwdf1mp1RtWUh+jV-Mg3GXDAqwQ@mail.gmail.com>
	<5508D6C1.2020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34192 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756452AbbCRMmA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 08:42:00 -0400
Received: by lagg8 with SMTP id g8so34832856lag.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 05:41:58 -0700 (PDT)
In-Reply-To: <5508D6C1.2020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 9:37 PM, Fan Du <fengyuleidian0615@gmail.com> w=
rote:
> =E4=BA=8E 2015=E5=B9=B403=E6=9C=8810=E6=97=A5 20:26, John Heffner =E5=
=86=99=E9=81=93:
>>
>> NACK.  From RFC4821:
>>
>>     In addition, the timely loss detection algorithms in most protoc=
ols
>>     have pre-conditions that SHOULD be satisfied before sending a pr=
obe.
>>     For example, TCP Fast Retransmit is not robust unless there are
>>     sufficient segments following a probe; that is, the sender SHOUL=
D
>>     have enough data queued and sufficient receiver window to send t=
he
>>     probe plus at least Tcprexmtthresh [RFC2760] additional segments=
=2E
>>     This restriction may inhibit probing in some protocol states, su=
ch as
>>     too close to the end of a connection, or when the window is too
>>     small.
>>
>
> Thanks for pointing this out for me.
>
> My limit understanding is the extra segments is used to trigger fast
> retransmit,
> and the conditions is the count of duplicate ack. Then why needs an e=
xtra
> one more
> segment here besides 'reordering' segment to trigger this?
>
> size_needed =3D probe_size + (tp->reordering + 1) * tp->mss_cache;
>                                             ^^^

I can't recall a particular reason for the plus one.  It may be
unnecessarily conservative.
