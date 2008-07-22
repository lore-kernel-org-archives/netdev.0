From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Recent tcp_syn_options() buglet
Date: Tue, 22 Jul 2008 05:40:42 +0400
Message-ID: <20080722014042.GA16846@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:17105 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbYGVBmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 21:42:14 -0400
Received: by fg-out-1718.google.com with SMTP id 19so791505fgg.17
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 18:42:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	  CHECK   net/ipv4/tcp_output.c
	net/ipv4/tcp_output.c:475:7: warning: dubious: !x & y


And sparse is damn right!

	if (unlikely(!OPTION_TS & opts->options))
		    ^^^
		size += TCPOLEN_SACKPERM_ALIGNED;

OPTION_TS is (1 << 1), so condition will never trigger.

