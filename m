From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Tue, 19 Jun 2007 16:11:55 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903111A87@orsmsx414.amr.corp.intel.com>
References: <20070619.153758.84956272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>,
	<kaber@trash.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59713 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754995AbXFSXL5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 19:11:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070619.153758.84956272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It's not being allocated at "compile time", it's being 
> allocated linearly into one block of ram in order to avoid 
> pointer derefs but it's still "dynamic" in that the size 
> isn't known until the alloc_netdev() call.
> 
> We do this trick all over the networking, TCP sockets are 3 
> or 4 different structures, all allocated into a linear block 
> of memory so that:
> 
> 1) only one memory allocation needs to be done for each object
>    create, this is not relevant for the net_device case
>    except in extreme examples bringing thousands of devices
>    up and down which I suppose someone can give a realistic
>    example of :-)
> 
> 2) each part can be accessed as an offset from the other instead
>    of a pointer deref which costs a cpu memory read
> 
> Please change the allocation strategy as I recommended, thanks.

Later this afternoon someone in my group came over and bonked me in the
head, and made this obvious to me.  Thanks for the follow-up; great
catch on the efficiency.  It's in my code now and is currently running
some test passes.

Thanks Dave,

-PJ Waskiewicz
