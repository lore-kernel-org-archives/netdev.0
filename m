From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [Bug 120441] af_packet no longer uses symmetric hashing
Date: Thu, 16 Jun 2016 11:32:55 -0400
Message-ID: <CAF=yD-Jcji5R6HTjV-ZoS+6-A2xz_Fq8CvhqaUSK-hLRc_Txnw@mail.gmail.com>
References: <511F6A17-BD35-4846-A717-1463B74D7F2A@gmail.com>
 <5762B9C0.9010902@iogearbox.net> <40238392-1c86-53ce-7722-51dd5c2dc294@stressinduktion.org>
 <5762C33C.7030404@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Derek Ditch <derek.ditch@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, jiri@resnulli.us,
	Willem de Bruijn <willemb@google.com>, eric@regit.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:35139 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893AbcFPPdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 11:33:46 -0400
Received: by mail-vk0-f48.google.com with SMTP id j2so78348818vkg.2
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 08:33:40 -0700 (PDT)
In-Reply-To: <5762C33C.7030404@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Isn't a symmetric hashing for af-packet something very fundamental?
>> Looks much more like a bug to me.
>
>
> I agree it would be useful resp. fundamental. I'm not quite sure whether
> PACKET_FANOUT_HASH always had this guarantee since the initial
> implementation

It is based on rxhash, which is intended to have this property. See for
instance the commit messages from commit b249dcb82d32 ("rps:
consistent rxhash")

"In case we compute a software skb->rxhash, we can generate a
consistent hash : Its value will be the same in both flow directions."

commit 6862234238e8 ("net: small bug on rxhash calculation") also
explicitly refers to this property.


> f.e. depending on whether the skb got fanout demuxed from RX or TX paths,
> you would either use a hw hash or it would have gone through the kernel's
> (predecessor) flow dissector

It's quite possible that not all hardware hash implementations do the
right thing, indeed.
