From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net] xen-netback: fix abuse of napi budget
Date: Tue, 10 Dec 2013 10:30:13 +0000
Message-ID: <52A6ED35.7070003@citrix.com>
References: <1386670600-5882-1-git-send-email-paul.durrant@citrix.com> <1386671136.11925.46.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <paul.durrant@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:11236 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787Ab3LJKaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:30:15 -0500
In-Reply-To: <1386671136.11925.46.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/13 10:25, Ian Campbell wrote:
> On Tue, 2013-12-10 at 10:16 +0000, Paul Durrant wrote:
>> netback seemed to be somewhat confused about the napi budget parameter and
>> basically ignored it. This patch fixes that, properly limiting the work done
>> in each poll.
> 
> What do you mean "ignored", xenvif_tx_submit seems to be tracking and
> testing work_done against the budget.

I have seen this warning in net_rx_action() trigger.

	WARN_ON_ONCE(work > weight);

Which means netback wasn't limiting the work done.

David
