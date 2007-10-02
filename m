From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 02 Oct 2007 23:02:53 +0200
Message-ID: <4702B1FD.70102@hartkopp.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131112.31727.5@janus.isnogud.escape.de> <20071002142016.GE7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:45392 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426AbXJBVDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:03:19 -0400
In-Reply-To: <20071002142016.GE7881@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Tue, Oct 02, 2007 at 03:10:11PM +0200, Urs Thuermann escreveu:
>   
>> +
>> +#ifdef CONFIG_CAN_DEBUG_DEVICES
>> +static int debug;
>> +module_param(debug, int, S_IRUGO);
>> +#endif
>>     
>
> Can debug be a boolean? Like its counterpart on DCCP:
>
> net/dccp/proto.c:
>
> module_param(dccp_debug, bool, 0444);
>   

'debug' should remain an integer to be able to specifiy debug-levels or 
bit-fields for different Debug outputs.

> Where we also use a namespace prefix, for those of us who use ctags or
> cscope.
>   

Even if i don't have any general objections to rename this 'debug' to 
'vcan_debug', it looks like an 'overnamed' module parameter for me. Is 
this a genereal naming scheme recommendation for debug module_params?

>
>> +/*
>> + * CAN test feature:
>> + * Enable the echo on driver level for testing the CAN core echo modes.
>> + * See Documentation/networking/can.txt for details.
>> + */
>> +
>> +static int echo; /* echo testing. Default: 0 (Off) */
>> +module_param(echo, int, S_IRUGO);
>> +MODULE_PARM_DESC(echo, "Echo sent frames (for testing). Default: 0 (Off)");
>>     
>
> echo also seems to be a boolean
>
>   

Yes. This is definitely a boolean candidate. We'll change that.

Thanks,
Oliver

