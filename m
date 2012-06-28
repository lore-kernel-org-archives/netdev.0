From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Thu, 28 Jun 2012 17:11:23 +0800
Message-ID: <CACVXFVOWZc4zA6GR+JrvDTaYVi0a6_3wgzm6TgfR_5bx9USEdQ@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<201206251410.13454.oliver@neukum.org>
	<CACVXFVO5x9pePZekJPnywr7czXG_3_xCRj-rXEgf2KSQXnmPbA@mail.gmail.com>
	<201206281035.19964.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38104 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755229Ab2F1JLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:11:24 -0400
In-Reply-To: <201206281035.19964.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 28, 2012 at 4:35 PM, Oliver Neukum <oneukum@suse.de> wrote:
> Am Dienstag, 26. Juni 2012, 09:23:19 schrieb Ming Lei:

>> IMO, probe is serialized strictly with driver unbind since both the parent
>> lock and its own device lock have been held, so the probe may only be
>> started after driver unbinding is completed.
>
> Yes, but if you have a driver which claims multiple interfaces and uses
> a subdriver, then you will have cases of intfdate being NULL before

We have no such case now.

> disconnect() finishes.

Suppose cdc-ether will support subdriver, ->unbind will set NULL to
the 2nd interface and release the 2nd interface, then subdriver->disconnect()
will be called, looks still no any problem.


Thanks,
-- 
Ming Lei
