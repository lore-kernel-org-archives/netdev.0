From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Wed, 21 Nov 2007 19:03:04 -0800
Message-ID: <20071121190304.6bf682b5@laptopd505.fenrus.org>
References: <20071122343.446909000@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59676 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbXKVDDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 22:03:12 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Nov 2007 03:43:06 +0100 (CET)
Andi Kleen <ak@suse.de> wrote:

> 
> There seems to be rough consensus that the kernel currently has too
> many exported symbols. A lot of these exports are generally usable
> utility functions or important driver interfaces; but another large
> part are functions intended by only one or two very specific modules
> for a very specific purpose. One example is the TCP code. It has most
> of its internals exported, but only for use by tcp_ipv6.c (and now a
> few more by the TCP/IP congestion modules) But it doesn't make sense
> to include these exported for a specific module functions into a
> broader "kernel interface".   External modules assume they can use
> these functions, but they were never intended for that.
> 
> This patch allows to export symbols only for specific modules by 
> introducing symbol name spaces. A module name space has a white
> list of modules that are allowed to import symbols for it; all others
> can't use the symbols.
> 
> It adds two new macros: 
> 
> MODULE_NAMESPACE_ALLOW(namespace, module);
> 
> Allow module to import symbols from namespace. module is the module
> name without .ko as displayed by lsmod.  Must be in the same module
> as the export (and be duplicated if there are multiple modules
> exporting symbols to a namespace).  Multiple allows for the same name
> space are allowed.
> 
> EXPORT_SYMBOL_NS(namespace, symbol);
> 

Hi,

I like this concept in general; I have one minor comment; right now
your namespace argument is like

EXPORT_SYMBOL_NS(foo, some_symbol);

from a language-like pov I kinda wonder if it's nicer to do

EXPORT_SYMBOL_NS("foo", some_symbol);

because foo isn't something in C scope, but more a string-like
identifier...



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
