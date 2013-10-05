From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: secure_seq: Move net_secret_init() definition
 into CONFIG_IPV6 if block
Date: Sat, 05 Oct 2013 16:27:52 -0400 (EDT)
Message-ID: <20131005.162752.155685316245760253.davem@davemloft.net>
References: <1381003790-12731-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, hannes@strressinduktion.org,
	netdev@vger.kernel.org, olof@lixom.net, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366Ab3JEU1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 16:27:55 -0400
In-Reply-To: <1381003790-12731-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Sat,  5 Oct 2013 17:09:50 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Commit 9a3bab6b05 (net: net_secret should not depend on TCP) introduced
> the following build warning when CONFIG_IPV6 is not selected:
> 
> net/core/secure_seq.c:17:13: warning: 'net_secret_init' defined but not used [-Wunused-function]
> 
> Fix it by moving net_secret_init(void) inside the '#if IS_ENABLED(CONFIG_IPV6)'
> block.
> 
> Reported-by: Olof Johansson <olof@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

seq_scale is used by secure_tcp_sequence_number, which is only protected
by CONFIG_INET.  I have no idea how you can get this build problem.

And I cannot reproduce it here:

[davem@drr net]$ egrep CONFIG_IPV6 .config
# CONFIG_IPV6 is not set
[davem@drr net]$ make net/core/secure_seq.o
scripts/kconfig/conf --silentoldconfig Kconfig
make[1]: Nothing to be done for `all'.
make[1]: Nothing to be done for `relocs'.
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CC      net/core/secure_seq.o
[davem@drr net]$ 

Furthermore your commit message is talking about net_secret_init but
your patch does things with seq_scale.

I'm not applying this patch.
