From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH net] bnx2x: prevent WARN during driver unload
Date: Wed, 8 Jan 2014 05:41:48 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF23FBC@SJEXCHMB10.corp.ad.broadcom.com>
References: <1389089261-25714-1-git-send-email-yuvalmin@broadcom.com>
 <20140107.154546.297973917685156649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:14925 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaAHFlu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 00:41:50 -0500
In-Reply-To: <20140107.154546.297973917685156649.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> > +	fp->state &= BNX2X_FP_STATE_DISABLED;
>  ...
> > +	fp->state &= BNX2X_FP_STATE_DISABLED;
> 
> Surely you mean "&= ~BNX2X_FP_STATE_DISABLED" here?

Thought the comment above the code was sufficient to show 
this is intentional.

The BNX2X_FP_STATE_DISABLED will cause BNX@X_FP_LOCKED to
Be true. The bnx2x_fp_ll_disable() works by setting this bit even
when BNX2X_FP_OWNED is set; while other flows release the lock
the will clear the bit indications except for the disabled indication,
so that no other flow could take the lock after it was disabled,
and the loop of bnx2x_fp_ll_disable() calls will eventually return true.

Thanks,
Yuval
