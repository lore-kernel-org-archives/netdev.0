From: Patrick McHardy <kaber@trash.net>
Subject: Re: net 04/05: fib_rules: allow to delete local rule
Date: Tue, 01 Dec 2009 18:38:47 +0100
Message-ID: <4B1554A7.2020701@trash.net>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <20091130175534.7555.48216.sendpatchset@x2.localnet> <1259673821.3168.35.camel@bigi> <20091201171214.GA7544@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org, robert@herjulf.net
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48382 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbZLARim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 12:38:42 -0500
In-Reply-To: <20091201171214.GA7544@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Kuznetsov wrote:
> Hello!
> 
>> Nice. I recall there was a lot of sentiment against this back
>> when - in particular from Alexey. I cant remember the details
> 
> Indeed, I refused to do this.
> 
> Sometimes, we have to determine that an address is local in a context
> where we do not have information to form a proper request to rule database.
> In this case we do direct lookup in fixed table, which is designated
> to contain local routes. So that rule 0 was hardwired to lookup in the
> same table.

Yes, you have to carefully set up your rules preceeding the local
rule when using this. Using marks or oif should work fine without
affecting the cases where we just need some information like the
device or addresses.

> Frankly, it will work provided we do not require too much of self-consistency.
> Those days I could not stand this, but it is not illegal.

In fact, you should already be able to do this by moving the
contents of the local table to a different one :)
