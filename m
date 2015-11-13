From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable <= 3.18] net: add length argument to
 skb_copy_and_csum_datagram_iovec
Date: Fri, 13 Nov 2015 16:29:10 -0500 (EST)
Message-ID: <20151113.162910.1252310731575005299.davem@davemloft.net>
References: <CAKA=qzZCi_OEDJKgy1WQ1QdMBpHBure1tY7NYtsgSr0fMva5jQ@mail.gmail.com>
	<20151111000352.GA5134@kroah.com>
	<20151112094822.GA21732@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, joshhunt00@gmail.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	stable@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbbKMV3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 16:29:12 -0500
In-Reply-To: <20151112094822.GA21732@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu, 12 Nov 2015 10:48:22 +0100

> 2015-11-10, 16:03:52 -0800, Greg Kroah-Hartman wrote:
>> On Tue, Nov 10, 2015 at 05:59:26PM -0600, Josh Hunt wrote:
>> > On Thu, Oct 29, 2015 at 5:00 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
>> > > 2015-10-15, 14:25:03 +0200, Sabrina Dubroca wrote:
>> > >> Without this length argument, we can read past the end of the iovec in
>> > >> memcpy_toiovec because we have no way of knowing the total length of the
>> > >> iovec's buffers.
>> > >>
>> > >> This is needed for stable kernels where 89c22d8c3b27 ("net: Fix skb
>> > >> csum races when peeking") has been backported but that don't have the
>> > >> ioviter conversion, which is almost all the stable trees <= 3.18.
>> > >>
>> > >> This also fixes a kernel crash for NFS servers when the client uses
>> > >>  -onfsvers=3,proto=udp to mount the export.
>> > >>
>> > >> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>> > >> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> > >
>> > > Fixes CVE-2015-8019.
>> > > http://www.openwall.com/lists/oss-security/2015/10/29/1
>> > >
>> > > --
>> > > Sabrina
>> > > --
>> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
>> > > the body of a message to majordomo@vger.kernel.org
>> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> > 
>> > Greg
>> > 
>> > Do you have this in your queue? I saw a few other stables pick this
>> > up, but haven't seen it in 3.14 or 3.18 yet. It wasn't clear to me if
>> > this had been fully reviewed yet.
>> 
>> I rely on Dave to package up networking stable patches and forward them
>> on to me, that's why you haven't seen it be picked up yet.
>> 
>> thanks,
>> 
>> greg k-h
> 
> David, can you queue this up?

This doesn't even apply to v3.18.24, the patched call site in
net/rxrpc/ar-recvmsg.c doesn't even exist.

Once you fix this up just submit it to -stable directly, I'm
fine with that for this.  I'm only handling submissions back
to v3.18 (4 releases) anyways.

Thanks.
