From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ewg] [PATCH 11/14] nes: OpenFabrics kernel verbs
Date: Wed, 08 Aug 2007 13:10:14 -0700
Message-ID: <adasl6tokih.fsf@cisco.com>
References: <200708080119.l781JRc2004874@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:2025 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934447AbXHHUKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 16:10:15 -0400
In-Reply-To: <200708080119.l781JRc2004874@neteffect.com> (ggrundstrom@neteffect.com's message of "Tue, 7 Aug 2007 20:19:27 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +static struct ib_mw *nes_alloc_mw(struct ib_pd *ibpd) {

 > +	get_random_bytes(&next_stag_index, sizeof(next_stag_index));

Could this use up a lot of entropy?  Is random32() sufficient?

 > +	stag_key = (u8)next_stag_index;

I don't think this cast is needed.

 > +	if (ret) {
 > +		return (ERR_PTR(ret));
 > +	}

Don't need braces for one-line blocks.

 > +	if (NULL == cqp_request) {

It's more idiomatic to write "if (!cqp_request) {"
