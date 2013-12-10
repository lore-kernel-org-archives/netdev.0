From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen-netback: fix abuse of napi budget
Date: Tue, 10 Dec 2013 10:37:36 +0000
Message-ID: <20131210103736.GJ32155@zion.uk.xensource.com>
References: <1386670600-5882-1-git-send-email-paul.durrant@citrix.com>
 <1386671136.11925.46.camel@kazak.uk.xensource.com>
 <52A6ED35.7070003@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:41367 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab3LJKhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 05:37:38 -0500
Content-Disposition: inline
In-Reply-To: <52A6ED35.7070003@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 10:30:13AM +0000, David Vrabel wrote:
> On 10/12/13 10:25, Ian Campbell wrote:
> > On Tue, 2013-12-10 at 10:16 +0000, Paul Durrant wrote:
> >> netback seemed to be somewhat confused about the napi budget parameter and
> >> basically ignored it. This patch fixes that, properly limiting the work done
> >> in each poll.
> > 
> > What do you mean "ignored", xenvif_tx_submit seems to be tracking and
> > testing work_done against the budget.
> 
> I have seen this warning in net_rx_action() trigger.
> 
> 	WARN_ON_ONCE(work > weight);
> 
> Which means netback wasn't limiting the work done.
> 

But in the original code work_done is returned by xenvif_tx_submit which
has guard against that situation, right?

Wei.

> David
