From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: netfront for review
Date: Thu, 03 May 2007 07:27:56 -0700
Message-ID: <4639F16C.3090005@goop.org>
References: <4637D672.5030706@goop.org> <1178077033.28659.173.camel@localhost.localdomain> <4638EAC0.7020107@goop.org> <46399057.4000409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:41194 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161936AbXECO16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 10:27:58 -0400
In-Reply-To: <46399057.4000409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerd Hoffmann wrote:
>> Gerd, in change 11196:b85da7cd9ea5 "front: Fix rx buffer leak when
>> tearing down an interface." you added a call to
>> "add_id_to_freelist(np->rx_skbs, id);".  However, rx_skbs doesn't have
>> an extra entry for the list head, and there's never any corresponding
>> get_id_from_freelist(np->rx_skbs).  What should it be?
>
> The function has an effect in page flipping mode only.  It walks the
> whole list of rx skbufs (id is the loop variable ...), checks whenever
> they are handed out to the frontend driver to fill in packet data and
> not returned yet, and if so reclaim them ...

Yes, but why use add_id_to_freelist?  rx_skbs are not being used on a
freelist anywhere else.  It just means the rx_skb array gets filled with
small integers, but the rest of the code assumes they're either NULL or
an skb pointer.

    J
