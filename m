From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Fix warning with
 CONFIG_OF=n
Date: Thu, 6 Apr 2017 07:32:36 -0700
Message-ID: <c6ca4d5c-2e09-2e51-acb7-9ec1113e1e3b@gmail.com>
References: <20170406134736.24329-1-f.fainelli@gmail.com>
 <20170406134736.24329-2-f.fainelli@gmail.com>
 <20170406140431.GA17713@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35190 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933624AbdDFOck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:32:40 -0400
Received: by mail-it0-f66.google.com with SMTP id y18so4527450itc.2
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 07:32:39 -0700 (PDT)
In-Reply-To: <20170406140431.GA17713@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/06/2017 07:04 AM, Andrew Lunn wrote:
> On Thu, Apr 06, 2017 at 06:47:35AM -0700, Florian Fainelli wrote:
>> When CONFIG_OF=n, we will see the following warning:
>>
>> drivers/net/dsa/mv88e6xxx/chip.c:2834:34: warning: 'mv88e6xxx_mdio_external_match' defined but not used [-Wunused-const-variable=]
>>  static const struct of_device_id mv88e6xxx_mdio_external_match[] = {
>>                                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
>> index 44ba8cff5631..64cbc4c04907 100644
>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>> @@ -2831,11 +2831,13 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
>>  	return 0;
>>  }
>>  
>> +#ifdef CONFIG_OF
>>  static const struct of_device_id mv88e6xxx_mdio_external_match[] = {
>>  	{ .compatible = "marvell,mv88e6xxx-mdio-external",
>>  	  .data = (void *)true },
>>  	{ },
>>  };
>> +#endif

Hi Andrew,

> 
> Hi Florian
> 
> Maybe a better fix is to make the stub of of_match_node() an inline
> function, so its parameters are used. That will fix this warning
> everywhere in the kernel, not just in this driver.

Good point, this is just much better.

Thanks!
-- 
Florian
