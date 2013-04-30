From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [IPROUTE PATCH v2] iproute2: act_ipt fix xtables breakage on
 older versions.
Date: Tue, 30 Apr 2013 08:59:58 -0400
Message-ID: <517FC04E.30705@mojatatu.com>
References: <20130429154644.52016.60284.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:49528 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759848Ab3D3NAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 09:00:05 -0400
Received: by mail-ie0-f170.google.com with SMTP id at1so531550iec.1
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 06:00:05 -0700 (PDT)
In-Reply-To: <20130429154644.52016.60284.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Alex,
Theres still some confusion on my part.

On 13-04-29 11:50 AM, Alexander Duyck wrote:

> The first is that xtables_merge_options only has 3 parameters.  It appears
> this is how this code was originally.

what you are describing above is still not making sense:

  As such for the case where the version
> is less than 6 I am assuming it would be correct to maintain the original
> setup that only had 3 parameters being passed instead of 4.
>

More below, lets just pick one of those:

> @@ -335,8 +338,7 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
>   					    m->x6_options,
>   					    &m->option_offset);
>   #else
> -		opts = xtables_merge_options(tcipt_globals.orig_opts,
> -					     tcipt_globals.opts,
> +		opts = xtables_merge_options(tcipt_globals.opts,
>   					     m->extra_opts,
>   					     &m->option_offset);
>   #endif
>


Here's the original equivalent change that you are updating:
-------
-                       tcipt_globals.opts =
-                           xtables_merge_options(
  #if (XTABLES_VERSION_CODE >= 6)
-                                                 tcipt_globals.orig_opts,
+               opts = xtables_options_xfrm(tcipt_globals.orig_opts,
+                                           tcipt_globals.opts,
+                                           m->x6_options,
+                                           &m->option_offset);
+#else
+               opts = xtables_merge_options(tcipt_globals.orig_opts,
+                                            tcipt_globals.opts,
+                                            m->extra_opts,
+                                            &m->option_offset);
  #endif
-                                                 tcipt_globals.opts,
-                                                 m->extra_opts,
-                                                 &m->option_offset);
------------------

I see, originally these parameters for xtables_merge_options():
tcipt_globals.orig_opts  <---- This is what you are trying to kill
tcipt_globals.opts
m->extra_opts
&m->option_offset

Which says there were 4 parameters to begin with....
Unless you are saying we had it wrong the first time. Pablo?

cheers,
jamal
