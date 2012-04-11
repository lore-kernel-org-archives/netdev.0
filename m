From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/5] team: add support for per-port options
Date: Wed, 11 Apr 2012 09:58:46 -0400 (EDT)
Message-ID: <20120411.095846.959856257051027757.davem@davemloft.net>
References: <1334070946-7704-2-git-send-email-jpirko@redhat.com>
	<20120410.143356.28893999541977853.davem@davemloft.net>
	<20120411054023.GA1955@minipsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab2DKN6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 09:58:53 -0400
In-Reply-To: <20120411054023.GA1955@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 11 Apr 2012 07:43:51 +0200

> Tue, Apr 10, 2012 at 08:33:56PM CEST, davem@davemloft.net wrote:
>>From: Jiri Pirko <jpirko@redhat.com>
>>Date: Tue, 10 Apr 2012 17:15:42 +0200
>>
>>> @@ -81,7 +81,16 @@ EXPORT_SYMBOL(team_port_set_team_mac);
>>>   * Options handling
>>>   *******************/
>>>  
>>> -struct team_option *__team_find_option(struct team *team, const char *opt_name)
>>> +struct team_option_inst { /* One for each option instance */
>>> +	struct list_head list;
>>> +	struct team_option *option;
>>> +	struct team_port *port; /* != NULL if per-port */
>>> +	bool changed;
>>> +	bool removed;
>>> +};
>>> +
>>
>>All this indirection... just simply embed struct team_option into
>>struct team_option_inst instead of using a pointer, and allocate a
>>full team_option_inst where you currently memdup in the options.
> 
> Well the list of options is needed alone. When port is added/removed, this list
> gets iterated over and instances are created/deleted. Therefore I put
> pointer to option to option instance struct to save memory (and also to
> be nicer)

Fair enough, I'll apply this series, thanks.
