From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: nf_nat_pptp 4.12.3 kernel lockup/reboot
Date: Mon, 24 Jul 2017 17:12:50 +0300
Message-ID: <69c0c47e920e763bce702521baae9caa@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:39734 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753249AbdGXOcF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 10:32:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to upgrade kernel 4.11.8 to 4.12.3 (it is a nat/router, 
handling approx 2gbps of pppoe users traffic) and noticed that after 
while server rebooting(i have set reboot on panic and etc).
I can't run serial console, and in pstore / netconsole there is nothing.
Best i got is some very short message about softlockup in ipmi, but as 
storage very limited there - it is near useless.

By preliminary testing (can't do it much, as it's production) - it seems 
following lines causing issue, they worked in 4.11.8 and no more in 
4.12.3.

iptables -t raw -A PREROUTING -p tcp -m tcp --dport 1723 -j CT --helper 
pptp
iptables -t raw -A PREROUTING -p tcp -m tcp --sport 1723 -j CT --helper 
pptp

(there is no solid examples for helpers, not sure second line is 
necessary)

I will try to do more tests tonight (lockdep debug and etc), but maybe 
someone have idea what might be wrong?
