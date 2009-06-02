From: Dan Carpenter <error27@gmail.com>
Subject: potential null dereference in proto_register()
Date: Tue, 2 Jun 2009 11:50:52 +0300 (EAT)
Message-ID: <alpine.DEB.2.00.0905271607370.11440@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f224.google.com ([209.85.219.224]:36057 "EHLO
	mail-ew0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbZFBJuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:50:15 -0400
Received: by ewy24 with SMTP id 24so8503612ewy.37
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 02:50:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a potential null dereference in proto_register() 
from net/core/sock.c

prot->rsk_prot can be null on line 2161 but we dereference it on line 
2167.

  2161  out_free_request_sock_slab:
  2162          if (prot->rsk_prot && prot->rsk_prot->slab) {
  2163                  kmem_cache_destroy(prot->rsk_prot->slab);
  2164                  prot->rsk_prot->slab = NULL;
  2165          }
  2166  out_free_request_sock_slab_name:
  2167          kfree(prot->rsk_prot->slab_name);

Found by smatch.

regards,
dan carpenter

