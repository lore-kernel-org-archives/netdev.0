From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix passing wrong parameter header to
 param_type2af in sctp_process_param
Date: Fri, 30 Jan 2015 17:45:43 -0800 (PST)
Message-ID: <20150130.174543.641220081613613919.davem@davemloft.net>
References: <1422525958-5737-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, saran.neti@telus.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320AbbAaBpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 20:45:44 -0500
In-Reply-To: <1422525958-5737-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 29 Jan 2015 11:05:58 +0100

> From: Saran Maruti Ramanara <saran.neti@telus.com>
> 
> When making use of RFC5061, section 4.2.4. for setting the primary IP
> address, we're passing a wrong parameter header to param_type2af(),
> resulting always in NULL being returned.
> 
> At this point, param.p points to a sctp_addip_param struct, containing
> a sctp_paramhdr (type = 0xc004, length = var), and crr_id as a correlation
> id. Followed by that, as also presented in RFC5061 section 4.2.4., comes
> the actual sctp_addr_param, which also contains a sctp_paramhdr, but
> this time with the correct type SCTP_PARAM_IPV{4,6}_ADDRESS that
> param_type2af() can make use of. Since we already hold a pointer to
> addr_param from previous line, just reuse it for param_type2af().
> 
> Fixes: d6de3097592b ("[SCTP]: Add the handling of "Set Primary IP Address" parameter to INIT")
> Signed-off-by: Saran Maruti Ramanara <saran.neti@telus.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
