From: David Miller <davem@davemloft.net>
Subject: Re: [patch 20/28] netconsole: Simplify boot/module option setup
 logic
Date: Fri, 10 Aug 2007 15:30:00 -0700 (PDT)
Message-ID: <20070810.153000.40145488.davem@davemloft.net>
References: <200708102112.l7ALC4HF009439@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org,
	k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59644
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932180AbXHJWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:30:01 -0400
In-Reply-To: <200708102112.l7ALC4HF009439@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:03 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.
> 
> Presently, boot/module parameters are set up quite differently for the case of
> built-in netconsole (__setup() -> obsolete_checksetup() ->
> netpoll_parse_options() -> strlen(config) == 0 in init_netconsole()) vs
> modular netconsole (module_param_string() -> string copied to the config
> variable -> strlen(config) != 0 init_netconsole() -> netpoll_parse_options()).
> 
> This patch makes both of them similar by doing exactly the equivalent of a
> module_param_string() in option_setup() also -- just copying the param string
> passed from the kernel command line into "config" variable.  So,
> strlen(config) != 0 in both cases, and netpoll_parse_options() is always
> called from init_netconsole(), thus making the setup logic for both cases
> similar.
> 
> Now, option_setup() is only ever called / used for the built-in case, so we
> put it inside a #ifndef MODULE, otherwise gcc will complain about
> option_setup() being "defined but not used".  Also, the "configured" variable
> is redundant with this patch and hence removed.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Acked-by: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
