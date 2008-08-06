From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2/m_ipt fix, opts was not set properly
Date: Wed, 6 Aug 2008 13:06:39 +0300
Message-ID: <200808061306.39846.denys@visp.net.lb>
References: <200808052224.36773.denys@visp.net.lb> <1218016372.4755.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:60935 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbYHFKH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:07:29 -0400
In-Reply-To: <1218016372.4755.15.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, jamal wrote:
> Are you sure this fixes any segfault? example, the variant you have
> below just changes a variable name:
>
> -----
> -static void free_opts(struct option *opts)
> +static void free_opts(struct option *opts_local)
>  {
> -       if (opts != original_opts) {
> -               free(opts);
> +       if (opts_local != original_opts) {
> +               free(opts_local);
>                 opts = original_opts;
>                 global_option_offset = 0;
>         }
> -------
>
> You could respin the patch with comment "change bad smelling name of
> a variable" - and that would be fine by me.

Make attention - before static void free_opts(struct option *opts) was 
shadowing global variable with same name *opts, after this patch - it will 
not shadow anymore.

