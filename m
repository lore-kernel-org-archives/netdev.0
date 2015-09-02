From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net: Add table id from route lookup to
 route response
Date: Wed, 02 Sep 2015 15:33:10 -0700 (PDT)
Message-ID: <20150902.153310.10595894847638285.davem@davemloft.net>
References: <55E74546.4070501@cumulusnetworks.com>
	<20150902190836.GD20527@pox.localdomain>
	<20150902194326.GZ504@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbbIBWdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 18:33:11 -0400
In-Reply-To: <20150902194326.GZ504@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Wed, 2 Sep 2015 15:43:27 -0400

> On Wed, Sep 02, 2015 at 09:08:36PM +0200, Thomas Graf wrote:
>> On 09/02/15 at 12:51pm, David Ahern wrote:
>> > On 9/2/15 12:49 PM, David Miller wrote:
>> > >From: Thomas Graf <tgraf@suug.ch>
>> > >Date: Wed, 2 Sep 2015 20:43:46 +0200
>> > >
>> > >>On 09/02/15 at 09:40am, David Ahern wrote:
>> > >>>rt_fill_info which is called for 'route get' requests hardcodes the
>> > >>>table id as RT_TABLE_MAIN which is not correct when multiple tables
>> > >>>are used. Use the newly added table id in the rtable to send back
>> > >>>the correct table.
>> > >>>
>> > >>>Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> > >>
>> > >>What RTM_GETROUTE returns is not the actual route but a description
>> > >>of the routing decision which is why table id, scope, protocol, and
>> > >>prefix length are hardcoded. This is indicated by the RTM_F_CLONED
>> > >>flag. What you propose would break userspace ABI.
>> > >
>> > >Agreed, I don't think we can do this.
>> > >
>> > 
>> > Doesn't the table used to come up with the decision matter for IPv4? ie.,
>> > hardcoding to MAIN is misleading when there is absolutely no way the
>> > decision comes from that table. IPv6 already returns the table id.
>> > 
>> > Or is your response that it breaks ABI and hence not going to fix.
>> 
>> This behaviour comes back from when we still had the IPv4 routing cache
>> which was flat.
> 
> So before the routing cache was removed, was the response always
> RTA_TABLE_MAIN since there was no way to indicate which table may have
> route if it came from the cache?

Right.  In fact, it was possible for routes from multiple tables to
end up evaluating to the same routing cache entry.  So there could be
a many to one relationship back then.
