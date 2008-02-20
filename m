From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: Dealing with limited resources and DMA Engine copies
Date: Wed, 20 Feb 2008 13:01:01 -0000
Message-ID: <7F38996F7185A24AB9071ED4950AD8C1012BD4C3@swsmsx413.ger.corp.intel.com>
References: <f12847240802200440u3542c2a0vaf82312435ddafe9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
To: <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64986 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbYBTNL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:11:27 -0500
Content-class: urn:content-classes:message
In-Reply-To: <f12847240802200440u3542c2a0vaf82312435ddafe9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>---------- Original message ----------
>From: Olof Johansson <olof@lixom.net>
>Date: Feb 14, 2008 3:38 AM
>Subject: Dealing with limited resources and DMA Engine copies
>To: shannon.nelson@intel.com, dan.j.williams@intel.com
>Cc: netdev@vger.kernel.org
>
>Hi,
>
>My DMA Engine has a limited resource: It's got a descriptor ring, so
>it's not always possible to add a new descriptor to it (i.e. it might
be
>full). While allocating a huge ring will help, eventually I'm sure I
>will hit a case where it'll overflow.
>
>I thought this was going to be taken care of automatically by the fact
>that you return your max(?) number of descriptors in the channel
>allocation function, but it looks like that value is discarded in
>dma_client_chan_alloc().
>
>So, I just got a couple of spurious:
>dma_cookie < 0
>dma_cookie < 0
>
>...on the console and the connection terminated. Looks like that came
>from tcp_recvmsg(). Ouch.
>
>How about falling back to the cpu-based copy in case of failure? Or
would
>you prefer that I sleep locally in my driver and wait on a descriptor
>slot to open up?
>

I have taken a closer look at this in the code. It seems to be a good
idea to withdraw for a while from ioat-dma copy in case of "dma_cookie <
0" error to let the ring free some descriptors.
I will be able to work on it next week probably. As soon as I have some
stable results, I will get back to you with it.

Maciej


---------------------------------------------------------------------
Intel Technology Poland sp. z o.o.
z siedziba w Gdansku
ul. Slowackiego 173
80-298 Gdansk

Sad Rejonowy Gdansk Polnoc w Gdansku, 
VII Wydzial Gospodarczy Krajowego Rejestru Sadowego, 
numer KRS 101882

NIP 957-07-52-316
Kapital zakladowy 200.000 zl

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

