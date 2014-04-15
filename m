From: Alexander Sverdlin <alexander.sverdlin@nsn.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Tue, 15 Apr 2014 10:46:03 +0200
Message-ID: <534CF1CB.9090502@nsn.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com> <20140414.164839.2032159104530481155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	matija.glavinic-pecotic.ext@nsn.com, vyasevich@gmail.com
To: ext David Miller <davem@davemloft.net>, dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:46660 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbaDOIqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 04:46:12 -0400
In-Reply-To: <20140414.164839.2032159104530481155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On 14/04/14 22:48, ext David Miller wrote:
>> This reverts commit ef2820a735f7 ("net: sctp: Fix a_rwnd/rwnd management
>> to reflect real state of the receiver's buffer") as it introduced a
>> serious performance regression on SCTP over IPv4 and IPv6, though a not
>> as dramatic on the latter. Measurements are on 10Gbit/s with ixgbe NICs.
>>
>> Current state:
>  ...
>> With the reverted patch applied, the SCTP/IPv4 performance is back
>> to normal on latest upstream for IPv4 and IPv6 and has same throughput
>> as 3.4.2 test kernel, steady and interval reports are smooth again.
>>
>> Fixes: ef2820a735f7 ("net: sctp: Fix a_rwnd/rwnd management to reflect real state of the receiver's buffer")
>> Reported-by: Peter Butler <pbutler@sonusnet.com>
>> Reported-by: Dongsheng Song <dongsheng.song@gmail.com>
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Tested-by: Peter Butler <pbutler@sonusnet.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> 
> Applied and queued up for -stable.

Should not this be fixed actually in SCTP congestion control part?
RWND calculation is actually not responsible for congestion control.
And this revert actually introduces serious bug again, which leads to SCTP being stuck completely in particular 
multi-homed use-cases (refer to http://www.spinics.net/lists/linux-sctp/msg02516.html).

We are not arguing against another version of the patch, but:
- you are choosing speed instead of stability here
- you are masking the problem reverting the code, which is not responsible for the problem observed

-- 
Best regards,
Alexander Sverdlin.
