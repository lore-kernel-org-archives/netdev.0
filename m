From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/3] net: Add table id from route lookup to
 route response
Date: Wed, 2 Sep 2015 21:08:36 +0200
Message-ID: <20150902190836.GD20527@pox.localdomain>
References: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
 <1441212034-37464-3-git-send-email-dsa@cumulusnetworks.com>
 <20150902184346.GB20527@pox.localdomain>
 <20150902.114914.1705777375118723461.davem@davemloft.net>
 <55E74546.4070501@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34560 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190AbbIBTIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 15:08:39 -0400
Received: by wicfx3 with SMTP id fx3so27577490wic.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 12:08:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55E74546.4070501@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 at 12:51pm, David Ahern wrote:
> On 9/2/15 12:49 PM, David Miller wrote:
> >From: Thomas Graf <tgraf@suug.ch>
> >Date: Wed, 2 Sep 2015 20:43:46 +0200
> >
> >>On 09/02/15 at 09:40am, David Ahern wrote:
> >>>rt_fill_info which is called for 'route get' requests hardcodes the
> >>>table id as RT_TABLE_MAIN which is not correct when multiple tables
> >>>are used. Use the newly added table id in the rtable to send back
> >>>the correct table.
> >>>
> >>>Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> >>
> >>What RTM_GETROUTE returns is not the actual route but a description
> >>of the routing decision which is why table id, scope, protocol, and
> >>prefix length are hardcoded. This is indicated by the RTM_F_CLONED
> >>flag. What you propose would break userspace ABI.
> >
> >Agreed, I don't think we can do this.
> >
> 
> Doesn't the table used to come up with the decision matter for IPv4? ie.,
> hardcoding to MAIN is misleading when there is absolutely no way the
> decision comes from that table. IPv6 already returns the table id.
> 
> Or is your response that it breaks ABI and hence not going to fix.

This behaviour comes back from when we still had the IPv4 routing cache
which was flat. I'm not against exposing the table id but you have
to use a new attribute for it.
