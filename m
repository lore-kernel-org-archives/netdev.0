From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Wed, 29 Apr 2009 11:16:37 +0200
Message-ID: <20090429091637.GA29874@elte.hu>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:49141 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbZD2JRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 05:17:35 -0400
Content-Disposition: inline
In-Reply-To: <49F71B63.8010503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> @@ -418,8 +429,16 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  				if (file) {
>  					f_op = file->f_op;
>  					mask = DEFAULT_POLLMASK;
> -					if (f_op && f_op->poll)
> +					if (f_op && f_op->poll) {
> +						if (wait) {
> +							wait->key = POLLEX_SET;
> +							if (in & bit)
> +								wait->key |= POLLIN_SET;
> +							if (out & bit)
> +								wait->key |= POLLOUT_SET;
> +						}
>  						mask = (*f_op->poll)(file, retval ? NULL : wait);
> +					}
>  					fput_light(file, fput_needed);
>  					if ((mask & POLLIN_SET) && (in & bit)) {
>  						res_in |= bit;

Please factor this whole 'if (file)' branch out into a helper. 
Typical indentation levels go from 1 to 3 tabs - 4 should be avoided 
if possible and 5 is pretty excessive already. This goes to eight.

	Ingo
