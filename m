From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 6/9] RDS: Fix ordering in a conditional
Date: Mon, 30 Mar 2009 21:27:53 -0700
Message-ID: <adak566e2pi.fsf@cisco.com>
References: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
	<1238438693-29540-7-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:46283 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbZCaE14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 00:27:56 -0400
In-Reply-To: <1238438693-29540-7-git-send-email-andy.grover@oracle.com> (Andy
	Grover's message of "Mon, 30 Mar 2009 11:44:50 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > -	if (0 <= ret && (unsigned) ret < nr_pages) {
 > +	if (ret > 0 && (unsigned) ret < nr_pages) {

This is not an equivalent transformation -- the original code is true if
ret == 0, while the new code is false.

Also it seems you don't need the unsigned cast here, since the clause
before just checked that ret is positive?

 - R.
