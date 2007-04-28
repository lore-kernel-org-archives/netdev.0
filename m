From: "Quan Sun" <cfk.quan@gmail.com>
Subject: Slow tcp handshakes rate of 2.6.20 and 2.6.19
Date: Sat, 28 Apr 2007 10:35:03 +0800
Message-ID: <e810d8480704271935l3a597d89g260bcb185c457937@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:64311 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbXD1CfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 22:35:04 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1163054wra
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 19:35:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  In these days I met a strange situation, tcp handshake rate is
slow after 2.6.18.8.

  The case is, server accepts connections, and records number of successful
tcp handshakes during last 10 seconds. Client tries to connect to server's
listen port as fast as possible and as many as possible, or in simple words,
client use connect() to flood the server.  In both cases, there are a log of syn
re-send.

  Server's performances varied much, depending on which kernel it was
running. On 2.6.18.8, 10000 successful connections take about 30-40 seconds,
while on 2.6.20 or 2.6.19, it will cost about more than 5 minutes.

   It seems there is some a mechanism which prevents connect() flood.
My problem is, is the mechanism exist, or there is some other reason(s)
for why 2.6.18 varies from 2.6.19/2.6.20?

   All these config files are all the same, tcp related options are,
CONFIG_INET_TCP_DIAG=m
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=m
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_IP_NF_TARGET_TCPMSS=m

-- 
Quan Sun
