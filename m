From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] genetlink: unify registration functions
Date: Mon, 18 Nov 2013 09:54:13 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7429@saturn3.aculab.com>
References: <1384521548-13241-1-git-send-email-johannes@sipsolutions.net> <20131115.205205.1547026485764326432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <johannes.berg@intel.com>
To: "David Miller" <davem@davemloft.net>, <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46742 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751266Ab3KRJzI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 04:55:08 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02622-05 for <netdev@vger.kernel.org>;
 Mon, 18 Nov 2013 09:55:04 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131115.205205.1547026485764326432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> As a future simplification perhaps we can even elide the array length
> argument.  Most pass ARRAY_SIZE(foo) but there is at least one case
> (DLM) which passes a constant, which is error prone.
> 
> #define genl_register_family_with_ops(family, ops)
> 	__genl_register_family_with_ops(family, ops, ARRAY_SIZE(ops))
> 
> something like that.

Probably best to add a compile time check that ARRAY_SIZE(ops)
isn't zero - as might happen if a pointer is passed.
In some cases this can happen even when the source code appears
to contain the array size.

Or does ARRAY_SIZE(x) already contain a check that
sizeof(x) % sizeof(*(x)) is zero?

	David
