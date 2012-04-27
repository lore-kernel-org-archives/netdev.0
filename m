From: Shan Wei <shanwei88@gmail.com>
Subject: [BUG report] net.core.rmem_default is larger than net.core.rmem_max
Date: Fri, 27 Apr 2012 17:31:22 +0800
Message-ID: <4F9A676A.8070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:51721 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623Ab2D0Jad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 05:30:33 -0400
Received: by dadz8 with SMTP id z8so772179dad.10
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 02:30:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's unconventional that "default" value  is greater than "max". :-(

net.core.rmem_max = 131071
net.core.rmem_default = 229376

net.core.wmem_max = 131071
net.core.wmem_default = 229376


And bisect the code to find the following commit caused this phenomenon.
This patch increase SK_WMEM_MAX and SK_RMEM_MAX which are used to 
initialize them.
But rmem_max and wmem_max value are still be covered according the RAM size
in sk_init().

87fb4b7b533073eeeaed0b6bf7c2328995f6c075 is the first bad commit
commit 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Oct 13 07:28:54 2011 +0000

    net: more accurate skb truesize
