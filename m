From: David Miller <davem@davemloft.net>
Subject: Re: For 3.14 [PATCH v3 net 1/3] xen-netback: remove pointless
 clause from if statement
Date: Sat, 29 Mar 2014 18:52:52 -0400 (EDT)
Message-ID: <20140329.185252.1161118508682129633.davem@davemloft.net>
References: <1396006747-9113-2-git-send-email-paul.durrant@citrix.com>
	<1298007319.20140328134550@eikelenboom.it>
	<1396011527.8670.42.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@eikelenboom.it, paul.durrant@citrix.com,
	xen-devel@lists.xen.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbaC2Wwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 18:52:54 -0400
In-Reply-To: <1396011527.8670.42.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Fri, 28 Mar 2014 12:58:47 +0000

> On Fri, 2014-03-28 at 13:45 +0100, Sander Eikelenboom wrote:
>> Friday, March 28, 2014, 12:39:05 PM, you wrote:
>> 
>> > This patch removes a test in start_new_rx_buffer() that checks whether
>> > a copy operation is less than MAX_BUFFER_OFFSET in length, since
>> > MAX_BUFFER_OFFSET is defined to be PAGE_SIZE and the only caller of
>> > start_new_rx_buffer() already limits copy operations to PAGE_SIZE or less.
>> 
>> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
>> > Cc: Ian Campbell <ian.campbell@citrix.com>
>> > Cc: Wei Liu <wei.liu2@citrix.com>
>> > Cc: Sander Eikelenboom <linux@eikelenboom.it>
>> > ---
>> >  drivers/net/xen-netback/netback.c |    4 ++--
>> >  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> > index 438d0c0..72314c7 100644
>> > --- a/drivers/net/xen-netback/netback.c
>> > +++ b/drivers/net/xen-netback/netback.c
>> > @@ -192,8 +192,8 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>> >          * into multiple copies tend to give large frags their
>> >          * own buffers as before.
>> >          */
>> > -       if ((offset + size > MAX_BUFFER_OFFSET) &&
>> > -           (size <= MAX_BUFFER_OFFSET) && offset && !head)
>> > +       BUG_ON(size > MAX_BUFFER_OFFSET);
>> > +       if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
>> >                 return true;
>> >  
>> >         return false;
>> 
>> For the whole v3 series:
>> 
>> Reported-By: Sander Eikelenboom <linux@eikelenboom.it>
>> Tested-By: Sander Eikelenboom <linux@eikelenboom.it>
>> 
>> CC'ed Dave to get his attention since this is a last minute for 3.14.
> 
> All three patches: Acked-by: Ian Campbell <ian.campbell@citrix.com>

Ok, we're coming down to the wire so this might not make it, but
I'll queue it up for -stable and get it merged when I can.

Thanks.
