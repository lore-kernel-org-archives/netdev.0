From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/3] net: Add table id from route lookup to
 route response
Date: Wed, 2 Sep 2015 20:43:46 +0200
Message-ID: <20150902184346.GB20527@pox.localdomain>
References: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
 <1441212034-37464-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38424 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbbIBSnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:43:49 -0400
Received: by wiclp12 with SMTP id lp12so28556769wic.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 11:43:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1441212034-37464-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 at 09:40am, David Ahern wrote:
> rt_fill_info which is called for 'route get' requests hardcodes the
> table id as RT_TABLE_MAIN which is not correct when multiple tables
> are used. Use the newly added table id in the rtable to send back
> the correct table.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

What RTM_GETROUTE returns is not the actual route but a description
of the routing decision which is why table id, scope, protocol, and
prefix length are hardcoded. This is indicated by the RTM_F_CLONED
flag. What you propose would break userspace ABI.
