From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Wed, 18 Oct 2006 20:31:09 -0700 (PDT)
Message-ID: <20061018.203109.63997999.davem@davemloft.net>
References: <45345999.4000300@psc.edu>
	<20061016.223513.35356292.davem@davemloft.net>
	<200610171458.37636.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52415
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030294AbWJSDbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:31:00 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610171458.37636.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet Hi <dada1@cosmosbay.com>
Date: Tue, 17 Oct 2006 14:58:37 +0200

> reqsk_queue_alloc() goal is to use a power of two size for the whole
> listen_sock structure, to avoid wasting memory for large backlogs,
> meaning the hash table nr_table_entries is not anymore a power of
> two. (Hence one AND (nr_table_entries - 1) must be replaced by
> MODULO nr_table_entries)

Modulus can be very expensive for some small/slow cpus.  Please round
down to a power-of-2 instead of up if you think the wastage really
matters.

Thanks.
