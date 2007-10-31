From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/8] Cleanup/fix the sk_alloc() call
Date: Wed, 31 Oct 2007 16:40:01 +0300
Message-ID: <472885B1.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41705 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754427AbXJaMhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 08:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sk_alloc() function suffers from two problems:
1 (major). The error path is not clean in it - if the security
   call fails, the net namespace is not put, if the try_module_get
   fails  additionally the security context is not released;
2 (minor). The zero_it argument is misleading, as it doesn't just 
   zeroes it, but performs some extra setup. Besides this argument 
   is used only in one place - in the sk_clone().

So this set fixes these problems and performs some additional
cleanup.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
