From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 13:50:56 +0200
Message-ID: <46669FA0.3030405@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain> <m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51578 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762323AbXFFLvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 07:51:20 -0400
In-Reply-To: <m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Reading through the patches they look usable to me.
> 
> Having to patch iproute to create the more interesting network
> devices sucks, but that problem seems fundamental.  We might
> be able to avoid it if we allowed fields to be reused between
> different types of devices but that makes the error checking
> trickier, and we aren't likely to have that many types of
> devices so there likely isn't much value in generalizing.


You don't really need to patch it, installing a new iplink_XXX.so
file is enough. Generalizing driver specific options more than
what we currently have doesn't look very promising. I think your
driver was simple enough to get along with the generic device
attributes though (IFLA_LINK or IFLA_MASTER).

> I do think we should specify the IFLA_KIND (was: IFLA_NAME) values in
> a header file.  So it is easy to get a list of all of the different
> kinds and so we don't conflict.


I don't think conflicts are going to be a problem (it would be
nice if modpost would warn about duplicate aliases though).
How is listing IFLA_KIND types in a header file going to help
get a list? Presuming the user knows what kind of device he
wants to set up and is not just looking for things to play
around with I also don't see any real value in this.

