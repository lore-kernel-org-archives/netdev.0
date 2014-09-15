From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: marvell: sky2.c: Cleaning up missing
 null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 16:56:20 -0400 (EDT)
Message-ID: <20140915.165620.1169777676117933052.davem@davemloft.net>
References: <20140914190557.690183d2@urahara>
	<20140915.130721.589682835868904320.davem@davemloft.net>
	<20140915135339.0659f618@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rickard_strandqvist@spectrumdigital.se, mlindner@marvell.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803AbaIOU4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 16:56:25 -0400
In-Reply-To: <20140915135339.0659f618@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 15 Sep 2014 13:53:39 -0700

> On Mon, 15 Sep 2014 13:07:21 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Sun, 14 Sep 2014 19:05:57 -0700
>> 
>> > On Sun, 14 Sep 2014 19:33:43 +0200
>> > Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> wrote:
>> > 
>> >> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
>> >> 
>> >> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>> >> ---
>> >>  drivers/net/ethernet/marvell/sky2.c |    2 +-
>> >>  1 file changed, 1 insertion(+), 1 deletion(-)
>> >> 
>> >> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
>> >> index dba48a5c..7053d38 100644
>> >> --- a/drivers/net/ethernet/marvell/sky2.c
>> >> +++ b/drivers/net/ethernet/marvell/sky2.c
>> >> @@ -4907,7 +4907,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
>> >>  	};
>> >>  
>> >>  	if (chipid >= CHIP_ID_YUKON_XL && chipid <= CHIP_ID_YUKON_OP_2)
>> >> -		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
>> >> +		strlcpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
>> >>  	else
>> >>  		snprintf(buf, sz, "(chip %#x)", chipid);
>> >>  	return buf;
>> > 
>> > Useless and unnecessary since the list of names is right there.
>> > Why not avoid the copy all together?
>> > 
>> > Subject: sky2: avoid strncpy
>> > 
>> > Don't use strncpy() since security thought police think it is bad.
>> > 
>> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> 
>> I think providing the buffer on the stack of the thread executing the
>> probe is superior because it will allow enabling parallel probing
>> in the future.
>> 
>> I don't think you have to change that aspect to achieve your goal
>> of returning the const char * string when possible.
> 
> What is benefit of s/strncpy/strlcpy/ for known safe code?
> Seems like more of the checkpatch police state.
> 

Stephen, read my reply again.

I didn't say to go back to the strlcpy change.

I said to use your patch, but keep the buf[] parameter allocated on
the caller's stack.

Thanks.
