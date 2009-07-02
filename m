From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Fri, 3 Jul 2009 02:13:42 +0300
Message-ID: <200907030213.42203.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907030022.55186.denys@visp.net.lb> <m1y6r6wwxy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45911 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZGBXOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 19:14:04 -0400
In-Reply-To: <m1y6r6wwxy.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 July 2009 01:18:33 Eric W. Biederman wrote:

and few more details

if i set 
"ip local-proxy-arp" on Fa 1/0

it still respects ARP Announce (as mypatch was doing, but mistake in patch it 
was not updating ARP cache)

home ~ # tcpdump -ni tap0 -vvv -s 1500
tcpdump: listening on tap0, link-type EN10MB (Ethernet), capture size 1500 
bytes
02:11:15.520588 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.1.8 
(ff:ff:ff:ff:ff:ff) tell 10.0.1.3, length 28
02:11:15.523696 ARP, Ethernet (len 6), IPv4 (len 4), Reply 10.0.1.8 is-at 
ca:00:0a:fc:00:1c, length 46
02:11:16.520616 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.1.8 
(ca:00:0a:fc:00:1c) tell 10.0.1.3, length 28
02:11:16.523365 ARP, Ethernet (len 6), IPv4 (len 4), Reply 10.0.1.8 is-at 
ca:00:0a:fc:00:1c, length 46
02:11:17.520635 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.1.8 
(ca:00:0a:fc:00:1c) tell 10.0.1.3, length 28
02:11:17.525146 ARP, Ethernet (len 6), IPv4 (len 4), Reply 10.0.1.8 is-at 
ca:00:0a:fc:00:1c, length 46
02:11:18.648310 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.1.3 
(ff:ff:ff:ff:ff:ff) tell 10.0.1.3, length 28
02:11:19.648364 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.1.3 
(ff:ff:ff:ff:ff:ff) tell 10.0.1.3, length 28
02:11:20.648421 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.1.3 
(ff:ff:ff:ff:ff:ff) tell 10.0.1.3, length 28

