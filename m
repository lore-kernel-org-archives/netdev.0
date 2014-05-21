From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] mISDN: Use time_before()
Date: Thu, 22 May 2014 00:43:29 +0400
Message-ID: <537D0FF1.2070708@cogentembedded.com>
References: <1400699406-31294-1-git-send-email-manuel.schoelling@gmx.de>	 <537CFE29.7050100@cogentembedded.com> <1400702866.11896.4.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Manuel_Sch=F6lling?= <manuel.schoelling@gmx.de>,
	isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400702866.11896.4.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/22/2014 12:07 AM, Joe Perches wrote:

>>> To be future-proof and for better readability the time comparisons are modified
>>> to use time_before() instead of plain, error-prone math.
>>> diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
> []
>>> @@ -287,7 +287,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, u8 channel, u32 chanmask,
>>>    	p = frame;
>>>
>>>    	/* restart timer */
>>> -	if ((int)(hc->keep_tl.expires-jiffies) < 5 * HZ) {
>>> +	if (time_before(hc->keep_tl.expires - 5 * HZ, jiffies)) {

>>      Wouldn't it be clearer this way:

>> 	if (time_before(hc->keep_tl.expires, jiffies + 5 * HZ)) {

>>>    		del_timer(&hc->keep_tl);
>>>    		hc->keep_tl.expires = jiffies + L1OIP_KEEPALIVE * HZ;
>>>    		add_timer(&hc->keep_tl);

> mod_timer?

    Done by the 2nd patch.

WBR, Sergei
