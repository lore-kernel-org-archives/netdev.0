From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NET]: Fix fib_rules dump race
Date: Thu, 22 Mar 2007 20:17:11 +0100
Message-ID: <20070322191711.GY521@postel.suug.ch>
References: <460294DB.7000507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55321 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbXCVTQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 15:16:51 -0400
Content-Disposition: inline
In-Reply-To: <460294DB.7000507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-03-22 15:38

> [NET]: Fix fib_rules dump race
> 
> fib_rules_dump needs to use list_for_each_entry_rcu to protect against
> concurrent changes to the rules list.

Good catch, it's not serialized with add/del by rtnl mutex if the
dump gets interrupted.
