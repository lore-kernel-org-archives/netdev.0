From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] Fix a race between sky2_down and sky2_poll.
Date: Tue, 02 Jun 2009 15:29:50 +0900
Message-ID: <4A24C6DE.1040301@ring3k.org>
References: <392fb48f0906011840n4914ef32x8aa316358b2ceacc@mail.gmail.com> <20090601210728.2be1a903@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:53719 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757695AbZFBGaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 02:30:18 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1657788wah.21
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 23:30:19 -0700 (PDT)
In-Reply-To: <20090601210728.2be1a903@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

>> -	/* Make sure no packets are pending */
>> -	napi_synchronize(&hw->napi);

> Down is also used during suspend/resume and changing MTU so this needs
> more inspection.

Could it be that the real problem is with the non-SMP case for 
napi_synchronize()?  The comment in include/linux/netdevice.h claims 
that napi_synchronize() "Waits till any outstanding processing 
completes..." but the implementation for non-SMP is just a barrier()...

Mike

