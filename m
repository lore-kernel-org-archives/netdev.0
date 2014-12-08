From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 2/2] rocker: remove swdev mode
Date: Mon, 8 Dec 2014 12:03:01 +0100
Message-ID: <20141208110301.GA1885@nanopsycho.brq.redhat.com>
References: <1417935267-6000-3-git-send-email-roopa@cumulusnetworks.com>
 <20141207081928.GA2215@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:52635 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754716AbaLHLDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 06:03:03 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so4332922wiw.8
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 03:03:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141207081928.GA2215@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 07, 2014 at 09:19:28AM CET, tgraf@suug.ch wrote:
>On 12/06/14 at 10:54pm, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> 
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>  drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
>>  include/linux/rtnetlink.h            |    2 +-
>>  net/core/rtnetlink.c                 |   12 +++++++++---
>>  3 files changed, 11 insertions(+), 21 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index fded127..9f1d256 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3755,7 +3739,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>  				      u32 filter_mask)
>>  {
>>  	struct rocker_port *rocker_port = netdev_priv(dev);
>> -	u16 mode = BRIDGE_MODE_SWDEV;
>> +	u16 mode = -1;
>        ^^^
>
>I assume you meant s16

well, I see no problem in using u16. IFLA_BRIDGE_MODE attr is u16 so
mode should stay u16.

But maybe better to add:
#define BRIDGE_MODE_UNDEF 0xFFFF

?
>
