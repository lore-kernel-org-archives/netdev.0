From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix socket code abuses csum_partial
Date: Tue, 04 Mar 2014 10:50:53 -0800
Message-ID: <1393959053.26794.126.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140304210104.42ef3dd8@kryten>
	 <20140304.134141.1732220919806520941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, edumazet@google.com, gustavold@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:63995 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbaCDSuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:50:55 -0500
Received: by mail-ig0-f177.google.com with SMTP id ur14so2158431igb.4
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 10:50:55 -0800 (PST)
In-Reply-To: <20140304.134141.1732220919806520941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-04 at 13:41 -0500, David Miller wrote:

> Alternatively you could just make unix_hash_fold() use csum_fold(),
> right?
> 
> static inline unsigned int unix_hash_fold(__wsum n)
> {
> 	unsigned int hash = (__force unsigned int) csum_fold(n);
> 
> 	hash ^= hash>>8;
> 	return hash&(UNIX_HASH_SIZE-1);
> }

Or simply use full_name_hash()
