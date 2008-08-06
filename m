From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2/m_ipt fix, opts was not set properly
Date: Wed, 06 Aug 2008 05:52:52 -0400
Message-ID: <1218016372.4755.15.camel@localhost>
References: <200808052224.36773.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:26564 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbYHFJw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 05:52:57 -0400
Received: by an-out-0708.google.com with SMTP id d40so492171and.103
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 02:52:55 -0700 (PDT)
In-Reply-To: <200808052224.36773.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys,

On Tue, 2008-05-08 at 22:24 +0300, Denys Fedoryshchenko wrote:
> Since opts global variable, if it is set to original_opts, it was done in 
> local context of function, and global variable in result was pointing to 
> freed memory. 
> Sure result of that - segfault, it is possible to trigger it 
> only while processing batch, cause only on next iteration opts was wrong.

Are you sure this fixes any segfault? example, the variant you have
below just changes a variable name:

-----
-static void free_opts(struct option *opts)
+static void free_opts(struct option *opts_local)
 {
-       if (opts != original_opts) {
-               free(opts);
+       if (opts_local != original_opts) {
+               free(opts_local);
                opts = original_opts;
                global_option_offset = 0;
        }
-------

You could respin the patch with comment "change bad smelling name of
a variable" - and that would be fine by me.

Please CC me on m_ipt or any of the other actions (as i have asked you
before).

cheers,
jamal

