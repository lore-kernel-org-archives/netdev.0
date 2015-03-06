From: Cong Wang <cwang@twopensource.com>
Subject: netns refcount leak
Date: Fri, 6 Mar 2015 15:29:49 -0800
Message-ID: <CAHA+R7PyGGjx_L_fMnBbTf8tgttqrH1d4LvLKR=CFB82CERoEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:43524 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbbCFX3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 18:29:50 -0500
Received: by iecrp18 with SMTP id rp18so21765781iec.10
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 15:29:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Ying


The following commit from you causes a netns refcount leak:

a62fbccecd62bacb4416fc427239f5b43b25d05e is the first bad commit
commit a62fbccecd62bacb4416fc427239f5b43b25d05e
Author: Ying Xue <ying.xue@windriver.com>
Date:   Fri Jan 9 15:27:11 2015 +0800

    tipc: make subscriber server support net namespace

    TIPC establishes one subscriber server which allows users to subscribe
    their interesting name service status. After tipc supports namespace,
    one dedicated tipc stack instance is created for each namespace, and
    each instance can be deemed as one independent TIPC node. As a result,
    subscriber server must be built for each namespace.

    Signed-off-by: Ying Xue <ying.xue@windriver.com>
    Tested-by: Tero Aho <Tero.Aho@coriant.com>
    Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


which prevents a netns being removed if I enable TIPC.

I am not familiar with TIPC code, please take a look.

Thanks!
