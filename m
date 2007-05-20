From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Sat, 19 May 2007 21:47:00 -0400
Message-ID: <464FA894.8090008@garzik.org>
References: <464B7127.5080502@gmail.com>	 <20070518180903.GC3492@tuxdriver.com> <1179622601.9453.4.camel@xo-28-0B-88.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Florin Malita <fmalita@gmail.com>, marcelo@kvack.org,
	linville@redhat.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59246 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756757AbXETBrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2007 21:47:11 -0400
In-Reply-To: <1179622601.9453.4.camel@xo-28-0B-88.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Fri, 2007-05-18 at 14:09 -0400, John W. Linville wrote:
>> On Wed, May 16, 2007 at 05:01:27PM -0400, Florin Malita wrote:
>>> In libertas_process_rxed_packet() and process_rxed_802_11_packet() the 
>>> skb is dereferenced after being passed to netif_rx (called from 
>>> libertas_upload_rx_packet). Spotted by Coverity (1658, 1659).
>>  
>> Relocating the libertas_upload_rx_packet call is fine, but...
>>
>>> Also, libertas_upload_rx_packet() unconditionally returns 0 so the error 
>>> check is dead code - might as well take it out.
>> Is this merely an implementation detail?  Or an absolute fact?
>> If the former is true, then we should preserve the error
>> checking.  If the latter, then we should change the signature of
>> libertas_upload_rx_packet to return void.
> 
> According to the comments, netif_rx always succeeds.  I think we should
> just change the return type to void since there's nothing else in that
> function that can fail.

According to the implementation, netif_rx() can fail.

	Jeff



