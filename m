From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Bug: tc filter show .... raise segfault if more than one rule
 with action -j MARK exist
Date: Fri, 9 May 2014 13:34:24 -0700
Message-ID: <20140509133424.7dc93da3@nehalam.linuxnetplumber.net>
References: <536B6F03.5040401@a-greve.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andreas.greve@a-greve.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:51715 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756913AbaEIUe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:34:27 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so4819726pab.7
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 13:34:26 -0700 (PDT)
In-Reply-To: <536B6F03.5040401@a-greve.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 May 2014 13:48:19 +0200
Andreas Greve <andreas.greve@a-greve.de> wrote:

> +	/* 
> +	   clone tcipt_globals because .opts and .options_offset  will be modified later and not 
> +           restored by iptables. If tcipt_globals is not cloned the modification tcipt_globals will 
> +           cause a segmentation fault if more than one filter rule  with action -j  exists.
> +        */
> +	struct xtables_globals tmp_tcipt_globals;
> +	memcpy (&tmp_tcipt_globals, &tcipt_globals, sizeof(struct xtables_globals) );
> +

Please use structure assignment instead of memcpy().
Structure assignment makes sure that types match. mempcpy does not.
