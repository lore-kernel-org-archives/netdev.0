From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute v2 2/5] ila: Support for configuring ila to use
 netfilter hook
Date: Sat, 6 Aug 2016 10:33:46 -0700
Message-ID: <20160806103346.56f7c33a@xeon-e3>
References: <1470342897-2004557-1-git-send-email-tom@herbertland.com>
	<269381334f4e4f2e9a40dd3f91129234@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemming@Brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35647 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbcHFU3f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2016 16:29:35 -0400
Received: by mail-pa0-f47.google.com with SMTP id iw10so102168609pac.2
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 13:29:34 -0700 (PDT)
In-Reply-To: <269381334f4e4f2e9a40dd3f91129234@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have no problem with this series in general and wanted to put it in before
closing the lid on 4.7 version, BUT.

This patch generates warnings when built on Debian Strech with gcc-5
 
ipila.c: In function ‘ila_parse_opt.constprop’:
ipila.c:205:2: warning: ‘locator_match’ may be used uninitialized in this function [-Wmaybe-uninitialized]
  addattr64(n, 1024, ILA_ATTR_LOCATOR_MATCH, locator_match);

	if (matches(*argv, "add") == 0)
> +		return do_add(argc-1, argv+1);
> +	if (matches(*argv, "delete") == 0)
> +		return do_del(argc-1, argv+1);
> +	if (matches(*argv, "list") == 0)
> +		return do_list(argc-1, argv+1);
> +	if (matches(*argv, "help") == 0)
> +		usage();
> +
> +	fprintf(stderr, "Command \"%s\" is unknown, try \"ip ila help\".\n",
> +		*argv);
> +	exit(-1);
> +}
> +

You also added a blank line at end of file.

Please fix this and resubmit the series.
