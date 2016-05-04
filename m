From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] vrf: add exit function and allow module unload
Date: Wed, 4 May 2016 12:24:55 +0200
Message-ID: <20160504102455.GB1947@nanopsycho.orion>
References: <1462357236-6297-1-git-send-email-jiri@resnulli.us>
 <1462357422.1666076.597731009.4C5E1305@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35491 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757383AbcEDKY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 06:24:58 -0400
Received: by mail-wm0-f53.google.com with SMTP id e201so181359204wme.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 03:24:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1462357422.1666076.597731009.4C5E1305@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 04, 2016 at 12:23:42PM CEST, hannes@stressinduktion.org wrote:
>Hello Jiri,
>
>On Wed, May 4, 2016, at 12:20, Jiri Pirko wrote:
>>  drivers/net/vrf.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>> 
>> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
>> index 8a8f1e5..b217c2d 100644
>> --- a/drivers/net/vrf.c
>> +++ b/drivers/net/vrf.c
>> @@ -839,7 +839,14 @@ error:
>>  	return rc;
>>  }
>>  
>> +static void __exit vrf_exit_module(void)
>> +{
>> +       rtnl_link_unregister(&vrf_link_ops);
>> +       unregister_netdevice_notifier(&vrf_notifier_block);
>> +}
>> +
>>  module_init(vrf_init_module);
>> +module_exit(vrf_exit_module);
>
>The dst_entries created by vrf don't carry a reference to THIS_MODULE
>but have a code dependency to the vrf module (e.g. via
>vrf_output/vrf_output6) that gets published. This is exactly the same
>why ipv6 cannot be unloaded.

Oh. Okay. Thanks!
