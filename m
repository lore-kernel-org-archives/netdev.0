From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 7/7] xen-netback: don't disconnect frontend when seeing oversize packet
Date: Tue, 9 Apr 2013 12:34:42 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71C5@saturn3.aculab.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com> <1365505655-8021-8-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<konrad.wilk@oracle.com>, <annie.li@oracle.com>,
	<wdauchy@gmail.com>
To: "Wei Liu" <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36332 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S935371Ab3DILfW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 07:35:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14813-04 for <netdev@vger.kernel.org>;
 Tue,  9 Apr 2013 12:35:17 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1365505655-8021-8-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +		if (!drop_err && txp->size > first->size) {
> +			if (net_ratelimit())
> +				netdev_dbg(vif->dev,
> +					   "Packet is bigger than frame.\n");

It must be worth printing txp->size and first->size here.
Similarly for the other errors in the other patches.

Probably difficult for some of these errors, but it is
sometimes worth saving the last 'bad' item. So that with
an appropriate tool (maybe hexdump of /dev/kmem) it is
possible to look at the actual contents and thus determine
the actual source of the error.

	David
