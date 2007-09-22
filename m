From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Sat, 22 Sep 2007 12:53:04 +0200
Message-ID: <46F4F410.3050607@trash.net>
References: <20070920184323.3795.0@janus.isnogud.escape.de>	<20070920184532.3795.2@janus.isnogud.escape.de>	<46F3BD75.6010904@trash.net> <ygfzlzfuccs.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53219 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbXIVLBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2007 07:01:17 -0400
In-Reply-To: <ygfzlzfuccs.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> 
>>You drop the module reference again when leaving this function.
>>So sock->ops might contain a stale pointer if the module is
>>unloaded after this. You need to either keep the module reference
>>while the socket is alive or remove stale references when
>>unregistering the protocol.
> 
> 
> I don't think that can happen.  Before we drop the module reference we
> call sk_alloc() which gets another module reference via its cp->prot
> argument.  If sk_alloc() fails we return with error from can_create()
> I assume sock->ops won't be used after that.


You're right, that should be enough.
