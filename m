From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCHv2 bluetooth-next 08/10] ipv6: export ndisc functions
Date: Sun, 8 May 2016 12:46:27 +0200
Message-ID: <bc3b76cc-c37c-53ab-4a1e-31212eab6dbe@pengutronix.de>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-9-git-send-email-aar@pengutronix.de>
 <f5d5970d-afed-8a2f-9292-9ccb77f0e0db@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48863 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750734AbcEHKqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 06:46:39 -0400
In-Reply-To: <f5d5970d-afed-8a2f-9292-9ccb77f0e0db@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On 05/02/2016 09:39 PM, Hannes Frederic Sowa wrote:
> On 20.04.2016 10:19, Alexander Aring wrote:
>> This patch exports some neighbour discovery functions which can be used
>> by 6lowpan neighbour discovery ops functionality then.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> Cc: James Morris <jmorris@namei.org>
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Signed-off-by: Alexander Aring <aar@pengutronix.de>
>> ---
>>  include/net/ndisc.h | 16 ++++++++++++++++
>>  net/ipv6/addrconf.c |  1 +
>>  net/ipv6/ndisc.c    | 28 ++++++++++------------------
>>  3 files changed, 27 insertions(+), 18 deletions(-)
>>
>> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
>> index 14ed016..35a4396 100644
>> --- a/include/net/ndisc.h
>> +++ b/include/net/ndisc.h
>> @@ -53,6 +53,15 @@ enum {
>>  
>>  #include <net/neighbour.h>
>>  
>> +/* Set to 3 to get tracing... */
>> +#define ND_DEBUG 1
>> +
>> +#define ND_PRINTK(val, level, fmt, ...)				\
>> +do {								\
>> +	if (val <= ND_DEBUG)					\
>> +		net_##level##_ratelimited(fmt, ##__VA_ARGS__);	\
>> +} while (0)
>> +
> 
> If the debug messages are well thought out, I think we could install
> them always on debug level.
> 
> There are valid users now, so
> 

Not sure if I understand you correctly here. Is this patch is fine or I
should remove ND_DEBUG, because it's handled by "net_##level##_ratelimited"
and the debug level will be handled then by other debug level settings
then?

Thanks.

- Alex
