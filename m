From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack crash, etc)
Date: 28 Jun 2016 09:23:01 -0400
Message-ID: <20160628132301.11479.qmail@ns.sciencehorizons.net>
References: <20160628124241.GA17940@gondor.apana.org.au>
Cc: linux-bluetooth@vger.kernel.org, linux-crypto@vger.kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au, linux@sciencehorizons.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.sciencehorizons.net ([71.41.210.147]:42138 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752786AbcF1NXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:23:09 -0400
In-Reply-To: <20160628124241.GA17940@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> I'm currently working on cts and I'm removing the stack usage
> altogether by having it operate on the src/dst SG lists only.

Wow, I should see how you do that.  I couldn't get it below 3
blocks of temporary, and the dst SG list only gives you
one and a half.

> BTW, the only cts user in our tree appears to be implementing
> CTS all over again and is only calling the crypto API cts for
> the last two blocks.  Someone should fix that.

Hint taken.  Although I'm having a hard time finding that only user
amidst all the drivers thinking it means Clear To Send or (for HDMI)
Cycle Time Stamp.

Um...the uses in fs/crypto/keyinfo.c and fs/ext4/crypto_key.c
don't seem to do anything untoward.

Is net/sunrpc/auth_gss/gss_krb5_mech.c doing something odd?


I have a request of you: like Andy, I find the crypto layer an
impenetrable thicket of wrapper structures.  I'm not suggesting there
aren't reasons for it, but it's extremely hard to infer those reasons by
looking at the code.  If I were to draft a (hilariously wrong) overview
document, would you be willing to edit it into correctness?
