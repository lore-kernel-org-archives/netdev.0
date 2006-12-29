From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Netchanel netfilter usage example.
Date: Fri, 29 Dec 2006 17:42:18 +0300
Message-ID: <20061229144218.GA32638@2ka.mipt.ru>
References: <20061229143527.GA20199@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55223 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028AbWL2Om0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 09:42:26 -0500
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.8/8.13.8) with ESMTP id kBTEgJk6001208
	for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 17:42:19 +0300
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.8/8.12.1/Submit) id kBTEgIKN001207
	for netdev@vger.kernel.org; Fri, 29 Dec 2006 17:42:18 +0300
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061229143527.GA20199@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 29, 2006 at 05:35:27PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> * netfilter netchannel backend (only NAT is supported as the most interesting
>   user, NAT caches appropriate route, so essentially routing becomes part
>   of the netchannel trie)

Source NAT example:

connctl -p 6-6 -t 0 -T 10.0.0.1 -s 192.168.0.0-255.255.248.0 -d
10.0.0.0-255.255.255.0 -S 80-80 -D 1234-1234

which is equivalent to

iptables -t nat -I POSTROUTING -p tcp -s 192.168.0.0/21 -d 10.0.0.0/24
--sport 80 --dport 1234 -j SNAT --to-source 10.0.0.1

Netchannels scale easily to tens of thousands entries, userspace test
showed scaling to millions of entries (consider system with one million
of netfilter rules or at least sockets).

-- 
	Evgeniy Polyakov
