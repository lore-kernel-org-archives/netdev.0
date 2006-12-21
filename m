From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [Netchannels] netchannels scalability.
Date: Thu, 21 Dec 2006 19:33:39 +0300
Message-ID: <20061221163338.GB10845@2ka.mipt.ru>
References: <20061220151245.GA19335@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41902 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422869AbWLUQeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 11:34:08 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061220151245.GA19335@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Script has create 22k wildcard (only one dimension (source address) 
is wildcard to save some mem) NAT rules
(16k $rand.$rand.$rand.$rand/255.255.248.0 rules and
(6k $rand.$rand.$rand.$rand/255.255.255.$rand).

I.e. it is equal to 22k following netfilter rules:
iptables -t nat -I POSTROUTING \
	-s $rand.$rand.$rand.$rand/255.255.248.0 \
	-d $static/$some_wildcard_mask \
	--sport $static_num/$some_wildcard_mask \
	--dport $static_num/$some_wildcard_mask \
	--proto $static_num/$some_wildcard_mask \
	-j SNAT --to-source $static_num

$static_num and $some_wildcard_mask are different on each line, but are
the same for different commands.

Raw send/recv performance over gigabit link is the same as described in
previous mail in this thread.

I can not test NAT processing speed itself (I do not have enough test
machines :).

Userspace trie tests included 1-2 millions insertions/searches.

Network performance of the netchannels userspace network stack remains
the same (userspace netchannel is one of the about thousands).

But I managed to crash test system with the latest patchset (netchannel 
addition is not protected against removing as must be done according to
RCU rules).

19 version of the netchannels subsystem patch only contains API
cleanup used with provided test case.

-- 
	Evgeniy Polyakov
