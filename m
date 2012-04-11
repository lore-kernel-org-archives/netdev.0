From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next 1/5] team: add support for per-port options
Date: Wed, 11 Apr 2012 07:43:51 +0200
Message-ID: <20120411054023.GA1955@minipsycho>
References: <1334070946-7704-1-git-send-email-jpirko@redhat.com>
 <1334070946-7704-2-git-send-email-jpirko@redhat.com>
 <20120410.143356.28893999541977853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab2DKGKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 02:10:33 -0400
Content-Disposition: inline
In-Reply-To: <20120410.143356.28893999541977853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 10, 2012 at 08:33:56PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Tue, 10 Apr 2012 17:15:42 +0200
>
>> @@ -81,7 +81,16 @@ EXPORT_SYMBOL(team_port_set_team_mac);
>>   * Options handling
>>   *******************/
>>  
>> -struct team_option *__team_find_option(struct team *team, const char *opt_name)
>> +struct team_option_inst { /* One for each option instance */
>> +	struct list_head list;
>> +	struct team_option *option;
>> +	struct team_port *port; /* != NULL if per-port */
>> +	bool changed;
>> +	bool removed;
>> +};
>> +
>
>All this indirection... just simply embed struct team_option into
>struct team_option_inst instead of using a pointer, and allocate a
>full team_option_inst where you currently memdup in the options.

Well the list of options is needed alone. When port is added/removed, this list
gets iterated over and instances are created/deleted. Therefore I put
pointer to option to option instance struct to save memory (and also to
be nicer)
