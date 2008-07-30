From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_hashlimit: fix race between htable_destroy and htable_gc
Date: Wed, 30 Jul 2008 12:53:44 +0200
Message-ID: <48904838.303@trash.net>
References: <4887A7DB.4030305@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4887A7DB.4030305@openvz.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Deleting a timer with del_timer doesn't guarantee, that the
> timer function is not running at the moment of deletion. Thus
> in the xt_hashlimit case we can get into a ticklish situation
> when the htable_gc rearms the timer back and we'll actually
> delete an entry with a pending timer.
> 
> Fix it with using del_timer_sync().
> 
> AFAIK del_timer_sync checks for the timer to be pending by
> itself, so I remove the check.

Also applied, thanks.
