From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause from if statement
Date: Thu, 27 Mar 2014 15:05:07 +0100
Message-ID: <184827204.20140327150507@eikelenboom.it>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com> <1395924973-42904-2-git-send-email-paul.durrant@citrix.com> <289461862.20140327144546@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029CA38@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:60619 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971AbaC0OFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:05:10 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD029CA38@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, March 27, 2014, 3:00:14 PM, you wrote:

>> -----Original Message-----
>> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> Sent: 27 March 2014 13:46
>> To: Paul Durrant
>> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell; Wei Liu
>> Subject: Re: [PATCH net v2 1/3] xen-netback: remove pointless clause from if
>> statement
>> 
>> 
>> Thursday, March 27, 2014, 1:56:11 PM, you wrote:
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
>> 
>> > v2:
>> >  - Add BUG_ON() as suggested by Ian Campbell
>> 
>> >  drivers/net/xen-netback/netback.c |    4 ++--
>> >  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
>> netback/netback.c
>> > index 438d0c0..72314c7 100644
>> > --- a/drivers/net/xen-netback/netback.c
>> > +++ b/drivers/net/xen-netback/netback.c
>> > @@ -192,8 +192,8 @@ static bool start_new_rx_buffer(int offset,
>> unsigned long size, int head)
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
>> Hi Paul,
>> 
>> Unfortunately .. no good ..
>> 
>> With these patches (v2) applied to 3.14-rc8 it all seems to work well,
>> until i do my test case .. it still chokes and now effectively permanently stalls
>> network traffic to that guest.
>> 
>> No error messages or anything in either xl dmesg or dmesg on the host .. and
>> nothing in dmesg in the guest either.
>> 
>> But in the guest the TX bytes ifconfig reports for eth0 still increase but RX
>> bytes does nothing, so it seems only the RX path is effected)
>> 
>> So it now seems i now have the situation which you described in the commit
>> message from "ca2f09f2b2c6c25047cfc545d057c4edfcfe561c",
>> "Without this patch I can trivially stall netback permanently by just doing a
>> large guest to guest file copy between two Windows Server 2008R2 VMs on a
>> single host."
>> 

> Assuming it is similar, then the tx queue should be stalled. It's possible the frontend is not posting enough rx requests into the ring to take the packet. Can you tell if this is happening?

How would i do that ?
(and it seems unlikely since that case that triggers is .. is swamping the interface with both inbound and outbound traffic)

>   Paul

>> --
>> Sander
