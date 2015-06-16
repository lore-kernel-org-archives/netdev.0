From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Wed, 17 Jun 2015 01:29:16 +0300
Message-ID: <5580A33C.4040007@cogentembedded.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>	 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>	 <5580821D.4080408@cogentembedded.com> <1434492550.2689.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julien Grall <julien.grall@citrix.com>,
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:35628 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbbFPW3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 18:29:21 -0400
Received: by lbbwc1 with SMTP id wc1so20054255lbb.2
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 15:29:19 -0700 (PDT)
In-Reply-To: <1434492550.2689.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/17/2015 01:09 AM, Joe Perches wrote:

>>> Append 0x to all %x in order to avoid while reading when there is other
>>> decimal value in the log.

> []

>>> @@ -874,7 +874,7 @@ static inline void xenvif_grant_handle_set(struct xenvif_queue *queue,
>>>    	if (unlikely(queue->grant_tx_handle[pending_idx] !=
>>>    		     NETBACK_INVALID_HANDLE)) {
>>>    		netdev_err(queue->vif->dev,
>>> -			   "Trying to overwrite active handle! pending_idx: %x\n",
>>> +			   "Trying to overwrite active handle! pending_idx: 0x%x\n",

>>      Using "%#x" is shorter ind does the same.

> That's true, but it's also far less common.

    Which is a pity... People just don't know the format specifiers well 
enough. :-(

> $ git grep -E "%#[\*\d\.]*x" | wc -l
> 1419
> $ git grep "0x%" | wc -l
> 29844

    Which means 29 KB could theoretically be saved on allyesconfig build. :-)
(Actually less since the width specifiers will likely need to be fixed where 
present.)

WBR, Sergei
