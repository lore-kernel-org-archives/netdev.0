From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: [patch 00/50] 2.6.25.6 -stable review
Date: Sun, 8 Jun 2008 13:56:01 +0200
Message-ID: <BAY103-DAV7370611E1B3FEA8FD69B9B2B10@phx.gbl>
References: <20080520.143238.87085088.davem@davemloft.net> <BAY103-DAV11AE409F40D0878FC3A259B2B60@phx.gbl> <20080607204325.GJ5609@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Chris Wright" <chrisw@sous-sol.org>
To: "Willy Tarreau" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s24.bay0.hotmail.com ([65.54.246.160]:62020 "EHLO
	bay0-omc2-s24.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758020AbYFHLvg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 07:51:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau wrote:

> On Sat, Jun 07, 2008 at 10:27:58PM +0200, Marco Berizzi wrote:
>> David Miller wrote:
>> 
>> > From: Herbert Xu <herbert@gondor.apana.org.au>
>> > Date: Tue, 20 May 2008 17:25:11 +0800
>> > 
>> >> On Wed, May 14, 2008 at 10:19:57AM +0200, Marco Berizzi wrote:
>> >> > 
>> >> > I hope this helps.
>> >> 
>> >> OK found the problem, it was my fault after all :)
>> >> 
>> >> Dave, this patch needs to go into stable too.
>> >> 
>> >> [IPSEC]: Use the correct ip_local_out function
>> >> 
>> >> Because the IPsec output function xfrm_output_resume does its
>> >> own dst_output call it should always call __ip_local_output
>> >> instead of ip_local_output as the latter may invoke dst_output
>> >> directly.  Otherwise the return values from nf_hook and dst_output
>> >> may clash as they both use the value 1 but for different purposes.
>> >> 
>> >> When that clash occurs this can cause a packet to be used after
>> >> it has been freed which usually leads to a crash.  Because the
>> >> offending value is only returned from dst_output with qdiscs
>> >> such as HTB, this bug is normally not visible.
>> >> 
>> >> Thanks to Marco Berizzi for his perseverance in tracking this
>> >> down.
>> >> 
>> >> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>> > 
>> > Applied and queued to -stable, thanks!
>> 
>> Hi David,
>> 
>> I don't see this patch in Chris 2.6.25.6 -stable review message.
> 
> Is it already in mainline ?

yes, since 2008/05/20
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1ac06e0306d0192a7a4d9ea1c9e06d355ce7e7d3

