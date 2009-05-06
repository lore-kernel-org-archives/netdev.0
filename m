From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 03/12] fs_enet: Add FEC TX Alignment workaround for
	MPC5121.
Date: Wed, 6 May 2009 16:42:55 -0600
Message-ID: <fa686aa40905061542g2cf538bau5eebcfc154906810@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <1241640919-4650-4-git-send-email-wd@denx.de>
	<fa686aa40905061337w6aa82f5aj787618ba108e528f@mail.gmail.com>
	<20090506221250.C977183420E8@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, netdev@vger.kernel.org,
	John Rigby <jcrigby@gmail.com>, Detlev Zundel <dzu@denx.de>
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:44615 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbZEFWnP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:43:15 -0400
Received: by yx-out-2324.google.com with SMTP id 3so237672yxj.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 15:43:15 -0700 (PDT)
In-Reply-To: <20090506221250.C977183420E8@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2009 at 4:12 PM, Wolfgang Denk <wd@denx.de> wrote:
> Dear Grant Likely,
>
> In message <fa686aa40905061337w6aa82f5aj787618ba108e528f@mail.gmail.c=
om> you wrote:
>>
>> > The FEC on 5121 has problems with misaligned tx buffers.
>> > The RM says any alignment is ok but empirical results
>> > show that packet buffers ending in 0x1E will sometimes
>> > hang the FEC. Other bad alignment does not hang but will
>> > cause silent TX failures resulting in about a 1% packet
>> > loss as tested by ping -f from a remote host.
>> >
>> > This patch is a work around that copies every tx packet
>> > to an aligned skb before sending.
>>
>> OUCH!
>
> Yes :-(
>
>> > +#else
>> > +#define tx_skb_align_workaround(dev, skb) (skb)
>> > +#endif
>>
>> Another use of #ifdef blocks. =A0What is the multiplatform impact?
>
> Hm... Can you recommend a better way to solve the problem? Suggestion=
s
> are welcome.

I'd rather see a runtime selectable workaround.  ie. enable it based
on the compatible property.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
