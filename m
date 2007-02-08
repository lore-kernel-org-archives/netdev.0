From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Thu, 8 Feb 2007 08:36:49 +0100
Message-ID: <20070208073649.GA1751@ff.dom.local>
References: <20070205101637.GB1863@ff.dom.local> <200702051814.13899.simonl@parknet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	Ingo Oeser <netdev@axxeo.de>
To: Simon Lodal <simonl@parknet.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60762 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422929AbXBHHdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 02:33:51 -0500
Content-Disposition: inline
In-Reply-To: <200702051814.13899.simonl@parknet.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 06:14:13PM +0100, Simon Lodal wrote:
...
> Regards
...

It seems decisions makers need more time, so I'd add 
2 cents more:

1c: an indentation could be improved (spaces around
operators), like in these places:

>+#define HTB_MAX_CLS		(TC_H_MIN(-1)+1)
...
>+	htb_cls_array* a;
...
>+	int cnt,done;

etc.

2c: it is a question of taste, but here:

> 		err = -ENOBUFS;
>+		if (q->classes[HTB_CLS_ARRAY(minorid)] == NULL) {
>+			if ((q->classes[HTB_CLS_ARRAY(minorid)] = 
>+			     kzalloc(sizeof(htb_cls_array), GFP_KERNEL))
>+			    == NULL)
>+				goto failure;
>+		}
> 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
> 			goto failure;

it would be probably more readable and a bit merciful
to the stressed system to free this htb_cls_array after
the last error (I know it's not a leak).

Regards,
Jarek P.

PS: 1c extra - it's easier to read a diff if you use -p option. 
