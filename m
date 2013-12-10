From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [Xen-devel] [PATCH net v5] xen-netback: fix fragment detection
 in checksum setup
Date: Tue, 10 Dec 2013 09:12:02 -0800
Message-ID: <1386695522.30495.349.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386092369-13618-1-git-send-email-paul.durrant@citrix.com>
	 <52A74B56020000780010BFB9@nat28.tlf.novell.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD01ACF1F@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Beulich <JBeulich@suse.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	David Miller <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:60880 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab3LJRMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:12:06 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so8064923pbb.2
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 09:12:05 -0800 (PST)
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD01ACF1F@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 16:24 +0000, Paul Durrant wrote:

> Yes, I guess that's true but if we decide to pull up at all then is it harmful to pull more than we absolutely need?

Pulling too many bytes might hurt aggregation.

When one skb is merged to another one (skb_try_coalesce()), if you have
payload in skb->head, we cannot free the head, and need one additional
'frag'
