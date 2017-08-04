From: Guoqing Jiang <gqjiang@suse.com>
Subject: WARN_ON in commit 0ffdaf5 "net/sock: add WARN_ON(parent->sk) in
 sock_graft()"
Date: Fri, 4 Aug 2017 19:13:18 +0800
Message-ID: <598456CE.7020702@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Guoqing Jiang <gqjiang@suse.com>
To: sowmini.varadhan@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.provo.novell.com ([137.65.250.81]:46869 "EHLO
        smtp2.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdHDLNc (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:0:0>);
        Fri, 4 Aug 2017 07:13:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI,

With commit 0ffdaf5b41cf4435ece14d1d3e977ce69012a20d "net/sock: add 
WARN_ON(parent->sk) in sock_graft()",
I can see the WARN_ON is triggered easily by dlm subsystem.

tcp_accept_from_sock() in  fs/dlm/lowcomms.c has the following snippet:

1.    result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
                                       SOCK_STREAM, IPPROTO_TCP, &newsock);
         sk is set by the path "sock_create_kern -> __sock_creat -> 
pf->create => inet_create -> sock_init_data"
     ...
2.    result = con->sock->ops->accept(con->sock, newsock, O_NONBLOCK, true);
         Then sock_graft is called by "con->sock->ops->accept => 
inet_accept -> sock_graft "

Does it mean call accept() after the just created socket is not a 
acceptable behavior? Any comment will be appreciate, thanks.

Regards,
Guoqing
