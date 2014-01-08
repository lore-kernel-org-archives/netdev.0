From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: prevent WARN during driver unload
Date: Wed, 08 Jan 2014 01:01:40 -0500 (EST)
Message-ID: <20140108.010140.283557207092663086.davem@davemloft.net>
References: <1389089261-25714-1-git-send-email-yuvalmin@broadcom.com>
	<20140107.154546.297973917685156649.davem@davemloft.net>
	<979A8436335E3744ADCD3A9F2A2B68A52AF23FBC@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaAHGBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 01:01:41 -0500
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AF23FBC@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Wed, 8 Jan 2014 05:41:48 +0000

>> 
>> > +	fp->state &= BNX2X_FP_STATE_DISABLED;
>>  ...
>> > +	fp->state &= BNX2X_FP_STATE_DISABLED;
>> 
>> Surely you mean "&= ~BNX2X_FP_STATE_DISABLED" here?
> 
> Thought the comment above the code was sufficient to show 
> this is intentional.
> 
> The BNX2X_FP_STATE_DISABLED will cause BNX@X_FP_LOCKED to
> Be true. The bnx2x_fp_ll_disable() works by setting this bit even
> when BNX2X_FP_OWNED is set; while other flows release the lock
> the will clear the bit indications except for the disabled indication,
> so that no other flow could take the lock after it was disabled,
> and the loop of bnx2x_fp_ll_disable() calls will eventually return true.

This bit handling is completely unintuitive.

The way a boolean state works is you manage it by setting it when
a condition arises, and clear it when a condition goes away.
