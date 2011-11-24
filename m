From: Jun Zhao <mypopydev@gmail.com>
Subject: [BUG] igmpv3 report bug ?
Date: Thu, 24 Nov 2011 23:19:12 +0800
Message-ID: <1322147954.9333.60.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38225 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab1KXPUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 10:20:18 -0500
Received: by yenl6 with SMTP id l6so277813yen.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 07:20:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David:

When Linux have a interface that is attached with SSM(Source-specific
multicast) and filter mode is EXCLUDE, if the multicast router send
group-and-source specific query to this interface for this group, Linux
respond this query with IS_EX record type.According to RFC 3376 $5.2
Page 24, need to respond this query with IS_IN record type.

+--------+              +--------+
|LINUX   |    < - >     |Router  |    
+--------+              +--------+

This is the step to reappear symptom.

1). LINUX join the SSM with EXCLUDE mode.Conceptually equivalent
IPMulticastListen ( interface, multicast-address,
                          EXCLUDE, source-list(A) )

2). Router send the group-and-source specific query to this interface
for this group. 
Query(multicast-address, source-list(B)).

3). Observe the igmpv3 report that send from LINUX, the respond is the
report with IS_EX record type.  
IS_EX(A)

Below is the action from RFC 3376 $ 5.2 Page 24:

                         set of sources in the
      interface state   pending response record   Current-State Record
      ---------------   -----------------------   --------------------
       EXCLUDE (A)               Query(B)          IS_IN (B-A)

This is linux action

                         set of sources in the
      interface state   pending response record   Current-State Record
      ---------------   -----------------------   --------------------
       EXCLUDE (A)               Query(B)          IS_EX (A)

I find MLDv2 have this symptom too.

Tks.
