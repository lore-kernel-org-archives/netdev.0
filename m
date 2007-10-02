From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 2 Oct 2007 18:43:25 -0300
Message-ID: <20071002214325.GB3576@ghostprotocols.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131112.31727.5@janus.isnogud.escape.de> <20071002142016.GE7881@ghostprotocols.net> <4702B1FD.70102@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.226]:7432 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbXJBVnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:43:35 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1615276qbe
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 14:43:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4702B1FD.70102@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 02, 2007 at 11:02:53PM +0200, Oliver Hartkopp escreveu:
> Arnaldo Carvalho de Melo wrote:
>> Em Tue, Oct 02, 2007 at 03:10:11PM +0200, Urs Thuermann escreveu:
>>   
>>> +
>>> +#ifdef CONFIG_CAN_DEBUG_DEVICES
>>> +static int debug;
>>> +module_param(debug, int, S_IRUGO);
>>> +#endif
>>>     
>>
>> Can debug be a boolean? Like its counterpart on DCCP:
>>
>> net/dccp/proto.c:
>>
>> module_param(dccp_debug, bool, 0444);
>>   
>
> 'debug' should remain an integer to be able to specifiy debug-levels or 
> bit-fields for different Debug outputs.
>
>> Where we also use a namespace prefix, for those of us who use ctags or
>> cscope.
>>   
>
> Even if i don't have any general objections to rename this 'debug' to 
> 'vcan_debug', it looks like an 'overnamed' module parameter for me. Is this 
> a genereal naming scheme recommendation for debug module_params?

[acme@mica linux-2.6.23-rc9-rt1]$ find . -name "*.c" | xargs grep
'module_param(.\+debug,' | wc -l
112
[acme@mica linux-2.6.23-rc9-rt1]$ find . -name "*.c" | xargs grep
'module_param(debug,' | wc -l
233
[acme@mica linux-2.6.23-rc9-rt1]$

I think that helping ctags to find the definition for the debug variable
to see, for instance, if it is a bitmask or a boolean without having to
chose from tons of 'debug' variables is a good thing.

- Arnaldo
