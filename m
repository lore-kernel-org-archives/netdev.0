From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 22:58:16 +0100
Message-ID: <46059EF8.6050603@trash.net>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61939 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbXCXV6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 17:58:22 -0400
In-Reply-To: <200703232307.l2NN7Rtg010808@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> [PPPOL2TP]: Add PPP-over-L2TP driver core.

A couple more comments:

- seq_file handling doesn't check seq_printf return values and
  tries to dump the entire hash table at once, which might
  exceed the available room.

- there appear to be no checks for duplicate session IDs on
  session creation.

- try_module_get/put_module in pppol2tp_create look unnecessary

- kfree can take NULL pointers

- direct dereference of user pointer in pppol2tp_sendmsg debugging

- jiffies.h includes conversion functions for HZ <-> msecs

- Any particular reason why the SKB_CB is put after inet_skb_parm?
  On 64 bit this almost reaches the limit, might be safer to put
  it at the beginning.

