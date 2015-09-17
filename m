From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: bcmgenet: Implement RX coalescing control
 knobs
Date: Thu, 17 Sep 2015 10:58:30 -0700
Message-ID: <55FAFF46.7010203@gmail.com>
References: <1442447260-14129-1-git-send-email-f.fainelli@gmail.com> <1442447260-14129-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36835 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbIQSCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 14:02:13 -0400
Received: by padhk3 with SMTP id hk3so25641626pad.3
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 11:02:13 -0700 (PDT)
In-Reply-To: <1442447260-14129-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/15 16:47, Florian Fainelli wrote:
> Add support for the ethtool rx-frames coalescing parameter which allows
> defining the number of RX interrupts per frames received. The RDMA
> engine supports a configurable timeout with a resolution of
> approximately 8.192 us.
> 
> We can no longer enable the BDONE/PDONE interrupts as those would
> fire for each packet/buffer received, which would defeat the MBDONE
> interrupt purpose. The MBDONE interrupt is guaranteed to correspond to a
> PDONE/BDONE interrupt when the threshold is set to 1.

*sigh*, I missed the initialization of the INTR_THRESHOLD register, so
right now, we just have no interrupts configured properly for RX, will
re-submit shortly.

Meanwhile, please send feedback if you have any, thanks!
-- 
Florian
