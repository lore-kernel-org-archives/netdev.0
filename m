From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Wed, 18 Jun 2008 23:27:01 -0700
Message-ID: <20080619062701.46a98ab1@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: jeff@garzik.org, netdev@vger.kernel.org, sathyap@serverengines.com
To: "Sam Ravnborg" <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:46202 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126AbYFSG1E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 02:27:04 -0400
In-Reply-To: 20080618184124.GA24826@uranus.ravnborg.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We could not get KBUILD_EXTRA_SYMBOLS to work.
This  is what we did :

beclib's Module.symvers has entries like this :

0x00000000      be_eq_destroy   /home/subbu/kod39-sperla/drivers/message/beclib/beclib  EXPORT_SYMBOL 

benet uses exports from beclib and we have the following line in benet's Makefile: 
KBUILD_EXTRA_SYMBOLS = $(src)/../../message/beclib/Module.symvers 

When we build benet we still get warnings like this
for symbols defined and exported from beclib :
WARNING: "be_eq_destroy" [/home/subbu/kod39-sperla/drivers/net/benet/benet.ko] undefined! 

Can you see what's wrong? 

Thanks.

Subbu


----- Original Message -----
From: Sam Ravnborg [mailto:sam@ravnborg.org]
To: Subbu Seetharaman [mailto:subbus@serverengines.com]
Cc: jeff@garzik.org, netdev@vger.kernel.org
Sent: Wed, 18 Jun 2008 11:41:24 -0700
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile


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

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

