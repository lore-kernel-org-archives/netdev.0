From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [1/1] connector: export cn_already_initialized.
Date: Tue, 16 May 2006 16:14:06 -0700 (PDT)
Message-ID: <20060516.161406.23276754.davem@davemloft.net>
References: <20060504122421.GA8576@2ka.mipt.ru>
	<20060505.171646.65488074.davem@davemloft.net>
	<20060506084045.GA16558@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52692
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932276AbWEPXOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 19:14:24 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060506084045.GA16558@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sat, 6 May 2006 12:40:45 +0400

> Some external patches, which can be built both as static build and as
> module just check that value, and thus will fail with unresolved symbol
> when cn and module are built as modules.
> 
> The right set of operations should be following:
> If external module is loaded and cn is not loaded or compiled into the
> kernel, insmod will just fail with unresolved symbol (cn_add_callback and others),
> if cn is already loaded or was built into the tree, then it has been 
> initialized already and there is no need to check that value, external
> module should be just loaded.
> 
> I think the right solution is to call external init functions after cn
> init function, but it's ordering is not always known.

In-kernel build of connector subsystem can be handled by
making cn_init a "subsystem_init()", it will then be setup
before any possible static or modular reference as long as
those modules use module_init().

For modular case of connector, dependency of module on connector
module should handle all ordering issues, making any ordering
issue take care of itself.
