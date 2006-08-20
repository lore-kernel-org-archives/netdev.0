From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 10:34:43 +0200
Message-ID: <200608201034.43588.ak@suse.de>
References: <20060819230532.GA16442@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <wtarreau@hera.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:41945 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751311AbWHTIet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2006 04:34:49 -0400
To: Solar Designer <solar@openwall.com>
In-Reply-To: <20060819230532.GA16442@openwall.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 20 August 2006 01:05, Solar Designer wrote:
> I propose the attached patch (extracted from 2.4.33-ow1) for inclusion
> into 2.4.34-pre.
> 
> (2.6 kernels could benefit from the same change, too, but at the moment
> I am dealing with proper submission of generic changes like this that
> are a part of 2.4.33-ow1.)

In general I don't think it makes sense to submit stuff for 2.4 
that isn't in 2.6.

> 
> The patch makes getsockopt(2) sanity-check the value pointed to by
> the optlen argument early on.  This is a security hardening measure
> intended to prevent exploitation of certain potential vulnerabilities in
> socket type specific getsockopt() code on UP systems.

It's not only insufficient on SMP, but even on UP where a thread
can sleep in get_user and another one can run in this time.

Doing a check that is inherently racy everywhere doesn't seem like
a security improvement to me. If there is really a length checking bug somewhere 
it needs to be fixed in a race-free way. If not then there is no need
for a change.

-Andi
