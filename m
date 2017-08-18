From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 5/5] tipc/bearer: Prevent NULL pointer
 dereference
Date: Fri, 18 Aug 2017 09:24:22 -0700
Message-ID: <20170818092422.3c178db7@xeon-e3>
References: <20170817170931.24545-1-phil@nwl.cc>
        <20170817170931.24545-6-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36170 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdHRQYb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:24:31 -0400
Received: by mail-pg0-f54.google.com with SMTP id i12so67441376pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:24:31 -0700 (PDT)
In-Reply-To: <20170817170931.24545-6-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:31 +0200
Phil Sutter <phil@nwl.cc> wrote:

> -	opt = get_opt(opts, "media");
> -	if (strcmp(opt->val, "udp") == 0) {
> +	if ((opt = get_opt(opts, "media")) &&
> +	    strcmp(opt->val, "udp") == 0) {

Please don't merge assignment and comparison unless necessary for other reasons.

	opt = get_opt(opts, "media");
	if (opt && strcmp(opt->val, "udp") == 0) {
