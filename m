From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: Bluetooth 6LoWPAN and routing
Date: Tue, 5 Nov 2013 09:52:56 +0100
Message-ID: <20131105085254.GA29547@omega>
References: <5268C214.2040307@linux.intel.com>
 <20131024122452.GA5491@omega>
 <52691711.3010909@linux.intel.com>
 <CAKT1EBeHs4T3YiFvze2RBbM537pXEj03gTcnCMEZprdBz882hg@mail.gmail.com>
 <1383640589.12691.36.camel@jrissane-mobl.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Claudio Takahasi <claudio.takahasi@openbossa.org>,
	netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:41602 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab3KEIxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 03:53:05 -0500
Received: by mail-ea0-f174.google.com with SMTP id n15so192498ead.5
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 00:53:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1383640589.12691.36.camel@jrissane-mobl.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

On Tue, Nov 05, 2013 at 10:36:29AM +0200, Jukka Rissanen wrote:
> Hi Claudio,
> 
> On ma, 2013-11-04 at 19:46 -0200, Claudio Takahasi wrote:
> > Hi Jukka,
> > 
> > On Thu, Oct 24, 2013 at 9:48 AM, Jukka Rissanen
> > <jukka.rissanen@linux.intel.com> wrote:
> > > Hi Alexander,
> > >
> > >
> > > On 24.10.2013 15:25, Alexander Aring wrote:
> > >>
> > >> Hi Jukka,
> > >>
> > >> On Thu, Oct 24, 2013 at 09:45:40AM +0300, Jukka Rissanen wrote:
> > >>>
> > >>> Hi,
> > >>>
> > >>> I have been prototyping with BT 6LoWPAN support (using this draft
> > >>> http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12 as a
> > >>> reference). I sent first version yesterday to linux-bluetooth ml
> > >>> http://thread.gmane.org/gmane.linux.bluez.kernel/39394
> > >>>
> > >> I see you take many code from the 6lowpan ieee802154 implementation.
> > >> (Just notice you drop the original authors from there)
> > >
> > >
> > > Hmm, those got dropped, I am sorry about that. I will add the original
> > > authors information of course.
> > >
> > >
> > >>
> > >> I have a couple of patches to fix a lot of bugs in the current 6LoWPAN
> > >> ieee802154 implementation.
> > >>
> > >> Some bugs which I found:
> > >>
> > >>    - Fix race conditions in fragmentation handling
> > >>    - Fix UDP compression/uncompressionm, which is completly broken
> > >>    - Fragmentation handling isn't rfc4944 compatible
> > >>
> > >> And some other improvements. I see your rfc has the same issues (e.g.
> > >> fragmentation race conditions).
> > >>
> > >> Currently I preparing these patches for mainlining.
> > >
> > >
> > > Excellent news!
> > 
> > 
> > Is it necessary to implement 6loWPAN fragmentation/reassembling? For
> > Bluetooth, I thought L2CAP FAR (Fragmentation and Reassembling) could
> > handle the transfer of IPv6 packets that doesn't fit in one single
> > BTLE PDU.
> 
> Yes, the Bluetooth 6lowpan code I sent handles the L2CAP FAR already.
> The question is who handles the IPv6 packets that are larger than
> IPV6_MIN_MTU (1280 bytes), or is that automatically done by other parts
> of the networking subsystem.
> 

In [1] you use the fragmentation according rfc4944 which isn't for
bluetooth correct. [2] says:

"Since FAR in BT-LE is a function of the L2CAP layer, fragmentation
functionality as defined in RFC 4944 [RFC4944] MUST NOT be used in
BT-LE networks."

MUST NOT, so you can't use it.

[1] http://article.gmane.org/gmane.linux.bluez.kernel/39397
    lowpan_process_data function and the first part of evaluating dispatch
    value. This code is the most ugly code in 6lowpan but I will rework
    it this right now... Only few problems with the skb_checksum because
    I uncompress the header after fragmentation(I think so).
    
    Of course that's only the receiving side, you need to check the
    transmit side.
[2] http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12#section-3.2

- Alex
