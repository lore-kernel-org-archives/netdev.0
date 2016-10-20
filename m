From: Matthias Peter Walther <m_walt11@uni-muenster.de>
Subject: Unexpected behaviour of suppress_prefixlength 0
Date: Fri, 21 Oct 2016 00:00:53 +0200
Message-ID: <64ccbd98-7717-8ca8-06c8-946a9370f4af@uni-muenster.de>
Reply-To: m.wa@wwu.de
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ZIVM-WWU3-1.UNI-MUENSTER.DE ([128.176.192.17]:3976 "EHLO
        zivm-wwu3.uni-muenster.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcJTWLk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 18:11:40 -0400
Received: from [192.168.178.23] (dslc-082-083-228-073.pools.arcor-ip.net [82.83.228.73])
        by SECMAIL.UNI-MUENSTER.DE (Postfix) with ESMTP id 813E0BF402
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 00:00:54 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm Matthias and I'm new to this list. I just signed up, to ask the 
following question.

I have a configuration like this:

root@des1 ~ # ip rule
0:    from all lookup local
32765:    from all iif lo lookup ffnet suppress_prefixlength 0
32766:    from all lookup main
32767:    from all lookup default
(ffnet is table 42)
root@des1 ~ # ip r s
default via 5.9.86.151 dev eth0
5.9.86.151 dev eth0  proto kernel  scope link  src 5.9.86.144
root@des1 ~ # ip r s t 42
blackhole default

I have the default routing table, and a routing table number 42. I could 
use an ip rule filtering by destination ip, but I wanted to try 
suppress_prefixlength.

Let's say I want to ping 8.8.8.8. What I expect is, that the package is 
put into routing table 42 by the ip rule 32765. As there is no more 
specific route for 8.8.8.8 than the default route in table 42, I expect 
the suppress_prefixlength 0 option to put it back to the default routing 
table and then to be send out through eth0.

Instead this configuration takes the whole machine offline:

root@des1 ~ # ping 8.8.8.8
connect: Invalid argument

When I delete the ip rule 32765 containing the suppress_prefixlength, 
the machine is back online.

Do I not understand the suppress_prefixlength-feature correctly or is 
this a bug? I tested with Kernel 4.7 and 4.6, both show the same 
behaviour as described above.

Thanks for any replies in advance.

Regards,
Matthias
