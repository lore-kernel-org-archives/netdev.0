From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC PATCH 00/17] fib_trie: Reduce time spent in fib_table_lookup
 by 35 to 75%
Date: Mon, 22 Dec 2014 10:08:09 -0800
Message-ID: <CAA93jw7Zz8_wToKOou42mXhgunZypQ6f=oGEHZk2K6CbrsrNqg@mail.gmail.com>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:61023 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957AbaLVSIJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:08:09 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp18so22204395obc.1
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 10:08:09 -0800 (PST)
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

impressive. I think. But I don't quite understand what you mean by a de=
pth of 7?

What did your routing table actually look like?

=46or example, my ipv4 routing table looks like this at the moment.

What is depth? searching from /32, /31, /30, /29?

root@davedesk:~# ip route
default via 172.21.2.21 dev se00  proto babel onlink
10.1.10.0/24 via 172.21.2.21 dev se00  proto babel onlink
10.1.10.12 via 172.21.2.21 dev se00  proto babel onlink
50.197.142.144/29 via 172.21.0.1 dev ge00  proto babel onlink
73.15.8.0/23 via 172.21.0.1 dev ge00  proto babel onlink
172.20.1.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.2.0/27 via 172.21.0.1 dev ge00  proto babel onlink
172.20.2.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.2.7 via 172.21.0.1 dev ge00  proto babel onlink
172.20.4.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.5.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.6.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.6.1 via 172.21.0.1 dev ge00  proto babel onlink
172.20.7.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.8.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.20.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.47.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.47.1 via 172.21.0.1 dev ge00  proto babel onlink
172.20.92.64/27 via 172.21.0.1 dev ge00  proto babel onlink
172.20.92.96/27 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.2 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.3 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.4 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.5 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.6 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.7 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.9 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.10 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.11 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.16 via 172.21.0.1 dev ge00  proto babel onlink
172.20.142.45 via 172.21.0.1 dev ge00  proto babel onlink
172.20.143.4 via 172.21.0.1 dev ge00  proto babel onlink
172.20.143.6 via 172.21.0.1 dev ge00  proto babel onlink
172.20.143.7 via 172.21.0.1 dev ge00  proto babel onlink
172.20.143.20 via 172.21.0.1 dev ge00  proto babel onlink
172.20.222.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.20.223.0/24 via 172.21.0.1 dev ge00  proto babel onlink
172.21.0.0/24 dev ge00  proto kernel  scope link  src 172.21.0.2
172.21.0.1 via 172.21.0.1 dev ge00  proto babel onlink
172.21.2.0/27 dev se00  proto kernel  scope link  src 172.21.2.1
172.21.2.20 via 172.21.2.20 dev se00  proto babel onlink
172.21.2.21 via 172.21.2.21 dev se00  proto babel onlink
172.21.2.64/27 dev sw00  proto kernel  scope link  src 172.21.2.65
172.21.2.96/27 dev sw10  proto kernel  scope link  src 172.21.2.97
172.21.2.128/27 dev gw00  proto kernel  scope link  src 172.21.2.129
172.21.2.160/27 dev gw10  proto kernel  scope link  src 172.21.2.161
172.21.128.0/24 via 172.21.2.21 dev se00  proto babel onlink
172.21.128.0/20 via 172.21.2.21 dev se00  proto babel onlink
172.21.129.0/24 via 172.21.2.21 dev se00  proto babel onlink
172.23.2.0/23 via 172.21.0.1 dev ge00  proto babel onlink
172.23.6.0/23 via 172.21.0.1 dev ge00  proto babel onlink
172.23.143.3 via 172.21.0.1 dev ge00  proto babel onlink
172.23.143.7 via 172.21.0.1 dev ge00  proto babel onlink
192.168.7.2 via 172.21.0.1 dev ge00  proto babel onlink


Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
