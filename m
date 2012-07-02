From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next v3] em_canid: Ematch rule to match CAN frames
 according to their identifiers
Date: Mon, 02 Jul 2012 20:03:27 +0200
Message-ID: <4FF1E26F.5000106@hartkopp.net>
References: <1341241568-13438-1-git-send-email-lisovy@gmail.com> <4FF1DF65.5080306@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:57262 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932136Ab2GBSD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 14:03:27 -0400
In-Reply-To: <4FF1DF65.5080306@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One more simplification:


>> +	rulescnt = len / sizeof(struct can_filter);
>> +
>> +	cm = kzalloc(sizeof(struct canid_match) + sizeof(struct can_filter) *
>> +		rulescnt, GFP_KERNEL);


No need to multiply the value again  ... you can take the len value as-is:

cm = kzalloc(sizeof(struct canid_match) + len, GFP_KERNEL);


> 
> *cm is no longer a fixed structure as it was in the first patches.
> 
> Must be:
> 
> m->datalen = sizeof(struct canid_match) + sizeof(struct can_filter) * rulescnt


dito:

m->datalen = sizeof(struct canid_match) + len;

Regards,
Oliver
