From: Linus Walleij <linus.walleij@stericsson.com>
Subject: Re: [PATCH 2/2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 11:25:09 +0200
Message-ID: <4EA7D1F5.2030904@stericsson.com>
References: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com> <20111026083838.GA9157@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert MARKLUND <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:49241 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932510Ab1JZJfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 05:35:21 -0400
In-Reply-To: <20111026083838.GA9157@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2011 10:38 AM, Mark Brown wrote:
> On Wed, Oct 26, 2011 at 10:05:56AM +0200, Linus Walleij wrote:
>
>    
>> +	/* enable/disable regulator for vddvario */
>> +	if (pdata->regulator_vddvario) {
>>      
> This has the same issue as last time - if you've got conditional code
> like this in the body of the driver something is going wrong.  Unless
> the supply is genuinely optional and might not be physically present on
> some systems the driver should fail if it can't get it.  The regulator
> API will stub itself out when not in use.
>    

That solves the issue for platforms with no regulator
support at all.

Then we have platforms with regulator support, but no
regulator for this hardware, because that one happens
to be always-on in these systems.

And they do not have CONFIG_REGULATOR_DUMMY
either.

So the driver probe will fail.

How do we solve this?

Shall we have CONFIG_SMC911X select
REGULATOR_DUMMY?

Yours,
Linus Walleij
