From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH v2 4/6] ath6kl: get rid of AR_DBG_LVL_CHECK()
Date: Fri, 6 Jan 2012 10:08:46 +0200
Message-ID: <4F06AC0E.1000809@qca.qualcomm.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF33@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <sfr@canb.auug.org.au>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-next@vger.kernel.org>,
	<ath6kl-devel@qualcomm.com>, <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF33@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2012 04:14 PM, David Laight wrote:
> 
>> We don't need it as debug calls already have a log level and
>> compiler should be smart enough to optimise away the code when
>> ath6kl debug code is not enabled.
> 
> Have you checked?

No, I just assumed so.

> I think you are assuming that because the called function collapses,
> the call will be removed allowing the loop to be removed. I suspect
> this is only true if the function is inlined. IIRC the normal linkage
> rules mean that only static functions are candidates for inlining.

I think you are right.

But while I investigated more I noticed that ath6kl_dump_registers()
will be an empty static inline whenever CONFIG_ATH6KL_DEBUG is disabled
and that will make sure that the whole function is not included. So
whenever ath6kl debug code is enabled there is a small performance hit,
but it's so small that IMHO we don't need to worry about it.

And for optimal performance CONFIG_ATH6KL_DEBUG should be disabled anyway.

What do you think?

Kalle
