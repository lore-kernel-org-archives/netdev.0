From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/14] tipc: Eliminate useless linked list
 initialization
Date: Tue, 17 Aug 2010 17:29:30 -0700 (PDT)
Message-ID: <20100817.172930.226785324.davem@davemloft.net>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
	<1282078816-11844-12-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47613
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752162Ab0HRA3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 20:29:12 -0400
In-Reply-To: <1282078816-11844-12-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 17 Aug 2010 17:00:13 -0400

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Eliminate the initialization of the port_list field of a newly created
> TIPC port, since the port is immediately added to TIPC's global list
> of ports (which alters the port_list field).
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

This is not correct.

INIT_LIST_HEAD() is mandatory for all new objects, since it may
initialize debugging knobs and whatnot inside of the list_head object
when certain debugging options are enabled.

Therefore it may never be elided.
