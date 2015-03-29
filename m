From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 0/2] ipv6: coding style - comparisons with NULL
Date: Sun, 29 Mar 2015 10:36:17 -0700
Message-ID: <1427650577.2715.32.camel@perches.com>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0030.hostedemail.com ([216.40.44.30]:59634 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752213AbbC2RgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 13:36:20 -0400
In-Reply-To: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-03-29 at 14:00 +0100, Ian Morris wrote:
> The IPV6 code uses multiple different styles when comparing with NULL
> (I.e. x == NULL and !x as well as x != NULL and x). Generally the
> latter form is preferred according to checkpatch and so this changes
> aligns the code to this style. 

Hello Ian.

While I prefer this style, it can be a "maintainer's choice"
preference and this might be a bit contentious to some.

It might be nice to show the relative counts of each form
before this change to show the relative counts use of each
form to help establish consensus for the value for this patch.

(Or David could just apply it instead:)

Using coccinelle to check for pointer comparisons with and
without NULL for net/ipv6/*.[ch]:

with NULL:	260
without NULL:	779

So there was a 3:1 preference for the bare form.

(and for net/ipv4/*.[ch] it's closer to 4:1)

with NULL:	276
without NULL:	914

(trivial cocci script below)
@@
type A;
A *b;
@@

* b == NULL

@@
type A;
A *b;
@@

* b != NULL
