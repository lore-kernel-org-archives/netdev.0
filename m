From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net: Add table id from route lookup to
 route response
Date: Wed, 02 Sep 2015 11:49:14 -0700 (PDT)
Message-ID: <20150902.114914.1705777375118723461.davem@davemloft.net>
References: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
	<1441212034-37464-3-git-send-email-dsa@cumulusnetworks.com>
	<20150902184346.GB20527@pox.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbbIBStP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:49:15 -0400
In-Reply-To: <20150902184346.GB20527@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 2 Sep 2015 20:43:46 +0200

> On 09/02/15 at 09:40am, David Ahern wrote:
>> rt_fill_info which is called for 'route get' requests hardcodes the
>> table id as RT_TABLE_MAIN which is not correct when multiple tables
>> are used. Use the newly added table id in the rtable to send back
>> the correct table.
>> 
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> What RTM_GETROUTE returns is not the actual route but a description
> of the routing decision which is why table id, scope, protocol, and
> prefix length are hardcoded. This is indicated by the RTM_F_CLONED
> flag. What you propose would break userspace ABI.

Agreed, I don't think we can do this.
