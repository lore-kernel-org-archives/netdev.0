From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Thu, 7 Jul 2016 10:55:37 +0100
Message-ID: <577E2719.6000303@citrix.com>
References: <577E279D02000078000FBEBF@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17986 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbcGGJzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 05:55:40 -0400
In-Reply-To: <577E279D02000078000FBEBF@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/16 08:57, Jan Beulich wrote:
> ... for single items being collected: It is more typesafe (as the
> compiler can check format string and to-be-written-to variable match)
> and requires one less parameter to be passed.

Do not split commit messages between the subject and the body in this
way.  The body should be a complete description of the commit,
independent of the subject.

It's annoying to find only half a sentence in the body and have to go
re-read the subject again.

e.g.,

"xen-netback: prefer xenbus_scanf() over xenbus_gather()

xenbus_scanf() is preferred over xenbus_gather() because: a) the
compiler can check the types match the format; and b) one less parameter
is needed.

Use xenbus_scanf() instead of xenbus_gather() when reading only a single
key."

I think almost all of your commit messages suffer from this, please redo
them all.

> --- 4.7-rc6-prefer-xenbus_scanf.orig/drivers/net/xen-netback/xenbus.c
> +++ 4.7-rc6-prefer-xenbus_scanf/drivers/net/xen-netback/xenbus.c
> @@ -842,16 +842,16 @@ static int connect_ctrl_ring(struct back
>  	unsigned int evtchn;
>  	int err;
>  
> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> -			    "ctrl-ring-ref", "%u", &val, NULL);
> -	if (err)
> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> +			   "ctrl-ring-ref", "%u", &val);
> +	if (err <= 0)

< 0

David
