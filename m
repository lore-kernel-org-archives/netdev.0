From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] Export the tcp sock's security context to proc.
Date: Tue, 09 Aug 2011 00:33:26 -0700 (PDT)
Message-ID: <20110809.003326.1002501904080430572.davem@davemloft.net>
References: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
	<1312874910-31010-7-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, sds@tycho.nsa.gov
To: rongqing.li@windriver.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1312874910-31010-7-git-send-email-rongqing.li@windriver.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <rongqing.li@windriver.com>
Date: Tue, 9 Aug 2011 15:28:30 +0800

>  	if (v == SEQ_START_TOKEN) {
>  		seq_printf(seq, "%-*s\n", TMPSZ - 1,
>  			   "  sl  local_address rem_address   st tx_queue "
>  			   "rx_queue tr tm->when retrnsmt   uid  timeout "
> -			   "inode");
> +			   "inode seclabel");
>  		goto out;
>  	}

Unfortunately you cannot change the layout of procfs file output in
this way.  It has the potential to break programs which are parsing
this file in userspace already.

The layout hasn't changed in a very long time because it is essentially
a uservisible ABI.

If you want to export new information you'll have to do it using the
facility that is extensible, and that's the netlink based socket dumping
facility implemented in inet_diag.c, tcp_diag.c and friends.

There, you can simply add a new netlink attribute that gets dumped with
the entry, which will provide the security context.

