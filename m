From: David Miller <davem@davemloft.net>
Subject: qdisc hash table changes...
Date: Mon, 08 Aug 2016 15:53:35 -0700 (PDT)
Message-ID: <20160808.155335.2122819330212870390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jikos@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34939 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbcHHXCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 19:02:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id h186so25689457pfg.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 16:02:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think there will still be build failures even with v6 due to symbol
clashes.

For example, kernel/audit_tree.c defines HASH_SIZE as an enumeration
value, and that (indirectly) includes networking headers.

There are others all over the tree.

I would therefore ask that you first fix the namespace conflicts
against the hash symbols in the entire tree as a separate patch series
(one for each driver/subsystem which has this problem.)  Really, get
it down to "git grep hash_add | grep -v _hash_add" and similar
returning no output.

Then we can add the qdisc hash facility.

Thanks.
