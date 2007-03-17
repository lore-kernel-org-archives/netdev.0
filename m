From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SK_BUFF]: Disable the offset code
Date: Fri, 16 Mar 2007 18:53:10 -0700 (PDT)
Message-ID: <20070316.185310.48528040.davem@davemloft.net>
References: <39e6f6c70703161842u5587058ep1d0eef8d794390b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933534AbXCQBxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 21:53:12 -0400
In-Reply-To: <39e6f6c70703161842u5587058ep1d0eef8d794390b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 16 Mar 2007 22:42:46 -0300

>         Please pull from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22
> 
>         Till I fully investigate and fix this we should just use the
> pointer based approach, where this problem bug doesn't happens, good
> thing its selectable :)

Pulled, let me know when you have a real fix :-)

For others, Arnaldo and I suspect that the failure case is
when an offset is negative.  Since the offsets are unsigned
and 32-bit this will do the wrong thing when used as an
offset of a 64-bit pointer as the 32-bit "negative" value
will be zero instead of sign-extended.

If this theory proves true, the fix is to make the offsets
signed 32-bit quantities.
