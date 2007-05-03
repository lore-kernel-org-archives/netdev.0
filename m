From: Keir Fraser <keir@xensource.com>
Subject: Re: netfront for review
Date: Thu, 03 May 2007 15:30:55 +0100
Message-ID: <C25FB0AF.E59B%keir@xensource.com>
References: <4639F16C.3090005@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>,
	Gerd Hoffmann <kraxel@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1162001AbXECObK@vger.kernel.org>
In-Reply-To: <4639F16C.3090005@goop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 3/5/07 15:27, "Jeremy Fitzhardinge" <jeremy@goop.org> wrote:

>> The function has an effect in page flipping mode only.  It walks the
>> whole list of rx skbufs (id is the loop variable ...), checks whenever
>> they are handed out to the frontend driver to fill in packet data and
>> not returned yet, and if so reclaim them ...
> 
> Yes, but why use add_id_to_freelist?  rx_skbs are not being used on a
> freelist anywhere else.  It just means the rx_skb array gets filled with
> small integers, but the rest of the code assumes they're either NULL or
> an skb pointer.

The need for it went away when Herbert Xu made the mapping between
receive-ring slots and receive-request/response identifiers static. I think
there was a race between Gerd writing his patch, Herbert removing the need
for add_id_to_freelist, and Gerd's patch being checked in.

 -- Keir
