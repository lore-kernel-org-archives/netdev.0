From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] net: stmmac: ensure jumbo_frm error return is correctly
 checked for -ve value
Date: Sat, 3 Jun 2017 17:35:22 +0100
Message-ID: <40331b09-5829-9041-f815-7f1426960bd8@canonical.com>
References: <20170602145827.21151-1-colin.king@canonical.com>
 <CAHp75VeuumsZHDdue=n-2esyG7Q-6472JoYJ64U0+OQoC2psgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:58407 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdFCQfZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 12:35:25 -0400
In-Reply-To: <CAHp75VeuumsZHDdue=n-2esyG7Q-6472JoYJ64U0+OQoC2psgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/17 16:55, Andy Shevchenko wrote:
> On Fri, Jun 2, 2017 at 5:58 PM, Colin King <colin.king@canonical.com> wrote:
>> The current comparison of entry < 0 will never be true since entry is an
>> unsigned integer. Cast entry to an int to ensure -ve error return values
>> from the call to jumbo_frm are correctly being caught.
> 
>>         if (unlikely(is_jumbo) && likely(priv->synopsys_id <
>>                                          DWMAC_CORE_4_00)) {
>>                 entry = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
>> -               if (unlikely(entry < 0))
>> +               if (unlikely((int)entry < 0))
> 
> It feels like a hiding some other issue.
> 

The alternative is:

		int rc = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
		if (unlikely(rc < 0))
			goto dma_map_err;

		entry = rc;

however, that is effectively the same. The cast I'm using is a well used
idiom in the kernel, it used in almost a hundred similar cases.

git grep "< 0" | grep "(int)" | wc -l
95

Colin
