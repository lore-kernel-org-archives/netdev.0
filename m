From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 10/14] rocker: pass "learning" value as a
 parameter to rocker_port_set_learning
Date: Mon, 5 Oct 2015 17:24:51 +0200
Message-ID: <20151005152451.GL2278@nanopsycho.orion>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
 <1443993949-3915-11-git-send-email-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6D1CBAC9ED@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"ast@plumgrid.com" <ast@plumgrid.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36282 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbJEPYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:24:54 -0400
Received: by wicgb1 with SMTP id gb1so124758692wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:24:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBAC9ED@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 05:16:31PM CEST, David.Laight@ACULAB.COM wrote:
>From: Jiri Pirko
>> Sent: 04 October 2015 22:26
>> Be consistent with the rest of the setting functions, and pass
>> "learning" as a bool function parameter.
>...
>> diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
>> index fb7e8c2..d9329a7 100644
>> --- a/drivers/net/ethernet/rocker/rocker_main.c
>> +++ b/drivers/net/ethernet/rocker/rocker_main.c
>> @@ -1634,6 +1634,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
>>  				  struct rocker_desc_info *desc_info,
>>  				  void *priv)
>>  {
>> +	bool learning = *(int *)priv;
>...
>> static int rocker_port_set_learning(struct rocker_port *rocker_port,
>> -				    struct switchdev_trans *trans)
>> +				    struct switchdev_trans *trans,
>> +				    bool learning)
>> {
>>  	return rocker_cmd_exec(rocker_port, trans, 0,
>>  			       rocker_cmd_set_port_learning_prep,
>> -			       NULL, NULL, NULL);
>> +			       &learning, NULL, NULL);
>
>This hit my 'casting between integer pointer types' bell.
>It is clearly wrong if 'sizeof (bool) != sizeof (int)'.


Oh, I c&p error - I'll fix "bool learning = *(int *)priv;" to:
"bool learning = *(bool *)priv;"
