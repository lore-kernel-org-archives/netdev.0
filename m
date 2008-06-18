From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Wed, 18 Jun 2008 20:41:24 +0200
Message-ID: <20080618184124.GA24826@uranus.ravnborg.org>
References: <20080618162041.9395b269@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:43281 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753632AbYFRSkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 14:40:41 -0400
Content-Disposition: inline
In-Reply-To: <20080618162041.9395b269@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 09:20:41AM -0700, Subbu Seetharaman wrote:
> Sam,
> 
> We could not find any good way to eliminate the unsresolved
> symbol warnings with the message code separated as
> a module.
There should not be any when building in-kernel.

If you build the two modules as external modules you need
to use a few tricks to get access to the symbol.
See Documentation/kbuild/modules.txt - look
for KBUILD_EXTRA_SYMBOLS

> Also, is there a way to prevent
> configuration of "y" for benet and "m" for beclib ?
IIRC a similar case is already described in 
Documentation/kbuild/kconfig-language.txt

But the simple solution is to let beclib be invisible
like this:

config BECLIB
	tristate

config BENET
	tristate "BE Module"
	select BECLIB
	depends on ...


Then BECLIB will have same value as BENET.
[Example only - use more appropriate names].

> What is the advantage of using benet-y instead
> of benet-objs ?

Lets say you have an optionla module that may
be selected in kconfig. Then you would do:

benet-y := benet-main.o benet-foo.o benet-bar.o ...
benet-$(OPTIONAL_FEATURE) += optional.o

>  I do not see net driver makefile
> using *-y. 
It is only recently I have started asking people to use -y for new stuff.
And no one has done any big effort to convert existing -objs users to -y
because that would mostly be code chrunch for little gain.
 

	Sam
