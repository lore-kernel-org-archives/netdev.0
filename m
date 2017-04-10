From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Horrid balance-rr bonding udp throughput
Date: Mon, 10 Apr 2017 14:50:40 -0400
Message-ID: <6f08f174-b087-32b7-91dd-ca72db50bd04@redhat.com>
References: <ea7fb030-f655-1658-14a6-6989e1e836ea@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752047AbdDJSul (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 14:50:41 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C9E1976E6
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 18:50:40 +0000 (UTC)
Received: from [172.31.27.133] (dhcp-17-185.bos.redhat.com [10.18.17.185])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 7F855179CD
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 18:50:40 +0000 (UTC)
In-Reply-To: <ea7fb030-f655-1658-14a6-6989e1e836ea@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-04-08 7:33 PM, Jarod Wilson wrote:
> I'm digging into some bug reports covering performance issues with 
> balance-rr, and discovered something even worse than the reporter. My 
> test setup has a pair of NICs, one e1000e, one e1000 (but dual e1000e 
> seems the same). When I do a test run in LNST with bonding mode 
> balance-rr and either miimon or arpmon, the throughput of the UDP_STREAM 
> netperf test is absolutely horrible:
> 
> TCP: 941.19 +-0.88 mbits/sec
> UDP: 45.42 +-4.59 mbits/sec
> 
> I figured I'd try LNST's packet capture mode, so exact same test, add 
> the -p flag and I get:
> 
> TCP: 941.21 +-0.82 mbits/sec
> UDP: 961.54 +-0.01 mbits/sec
> 
> Uh. What? So yeah. I can't capture the traffic in the bad case, but I 
> guess that gives some potential insight into what's not happening 
> correctly in either the bonding driver or the NIC drivers... More 
> digging forthcoming, but first I have a flooded basement to deal with, 
> so if in the interim, anyone has some insight, I'd be happy to hear it. :)

Okay, ignore the bit about bonding, I should have eliminated the bond 
from the picture entirely. I think the traffic simply ended up on the 
e1000 on the non-capture test and on the e1000e for the capture test, as 
those numbers match perfectly with straight NIC to NIC testing, no bond 
involved. That said, really odd that the e1000 is so severely crippled 
for UDP, while TCP is still respectable. Not sure if I have a flaky NIC 
or what...

For reference, e1000 to e1000e netperf:

TCP_STREAM: Measured rate was 849.95 +-1.32 mbits/sec
UDP_STREAM: Measured rate was 44.73 +-5.73 mbits/sec


-- 
Jarod Wilson
jarod@redhat.com
