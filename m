From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Tue, 16 Jun 2015 15:09:10 -0700
Message-ID: <1434492550.2689.8.camel@perches.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
	 <5580821D.4080408@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Julien Grall <julien.grall@citrix.com>,
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0138.hostedemail.com ([216.40.44.138]:47225 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750905AbbFPWJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 18:09:13 -0400
In-Reply-To: <5580821D.4080408@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-16 at 23:07 +0300, Sergei Shtylyov wrote:
> On 06/16/2015 10:10 PM, Julien Grall wrote:
> > Append 0x to all %x in order to avoid while reading when there is other
> > decimal value in the log.
[]
> > @@ -874,7 +874,7 @@ static inline void xenvif_grant_handle_set(struct xenvif_queue *queue,
> >   	if (unlikely(queue->grant_tx_handle[pending_idx] !=
> >   		     NETBACK_INVALID_HANDLE)) {
> >   		netdev_err(queue->vif->dev,
> > -			   "Trying to overwrite active handle! pending_idx: %x\n",
> > +			   "Trying to overwrite active handle! pending_idx: 0x%x\n",
> 
>     Using "%#x" is shorter ind does the same.

That's true, but it's also far less common.

$ git grep -E "%#[\*\d\.]*x" | wc -l
1419
$ git grep "0x%" | wc -l
29844
