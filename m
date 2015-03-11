From: Vadim Kochan <vadim4j@gmail.com>
Subject: iproute2: ip netns: Do not delete netns if there any process use it
Date: Wed, 11 Mar 2015 09:40:20 +0200
Message-ID: <20150311074020.GA26477@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:37214 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbbCKHv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 03:51:57 -0400
Received: by lbdu10 with SMTP id u10so6982632lbd.4
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 00:51:56 -0700 (PDT)
Received: from angus-think.wlc.globallogic.com ([195.234.75.250])
        by mx.google.com with ESMTPSA id ed5sm555001lbb.40.2015.03.11.00.51.55
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 00:51:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

There might be case when it is possible to loose device which was
moved to netns if there is process which is running is that netns:

    $ ip netns add net
    $ ip link set dev eth0 netns net0
    $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
    $ ip netns del net0

so eth0 will not appear in the default netns until SOME_PROCESS_IN_BACKGROUND will exit or
will ne killed. So to avoid such case it might be better to do not
delete netns if there are process in it ? I meant add such validation
for 'ip netns del' command.

What do you think ?

Thanks,
Vadim Kochan
