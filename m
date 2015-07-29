From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Simplified API over the FIB Trie
Date: Wed, 29 Jul 2015 14:57:39 +0200
Message-ID: <CAHmME9p7Q4gwsGKLmhSVnFxUAFzr7TB=cJfTkGrH+DmEvAFm+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:47341 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507AbbG2M5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:57:43 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id e9f2b090
	for <netdev@vger.kernel.org>;
	Wed, 29 Jul 2015 12:57:03 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 77482af7
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=YES
	for <netdev@vger.kernel.org>;
	Wed, 29 Jul 2015 12:57:03 +0000 (UTC)
Received: by laah7 with SMTP id h7so5706362laa.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 05:57:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

In a module I'm working on, I need a data structure that's similar to
a routing table. I'm looking at net/ip_fib.h and net/ip6_fib.h as a
means for doing this, but it's wildly complex. What I'm looking for is
something with a basic API like this:

http://codepad.org/S36n9t7W

=-=-=-=-=-=BEGIN API-=-=-=-=-=-=
int routing_table_v4_insert(struct routing_table_v4 *table, const
struct in_addr *ip, uint8_t cidr, void *value);
void *routing_table_v4_lookup(struct routing_table_v4 *table, const
struct in_addr *ip);
void *routing_table_v4_lookup_exact(struct routing_table_v4 *table,
const struct in_addr *ip, uint8_t cidr);
int routing_table_v4_remove_by_key(struct routing_table_v4 *table,
const struct in_addr *ip, uint8_t cidr);
int routing_table_v4_remove_by_value(struct routing_table_v4 *table,
void *value);

int routing_table_v6_insert(struct routing_table_v6 *table, const
struct in6_addr *ip, uint8_t cidr, void *value);
void *routing_table_v6_lookup(struct routing_table_v6 *table, const
struct in6_addr *ip);
void *routing_table_v6_lookup_exact(struct routing_table_v6 *table,
const struct in6_addr *ip, uint8_t cidr);
int routing_table_v6_remove_by_key(struct routing_table_v6 *table,
const struct in6_addr *ip, uint8_t cidr);
int routing_table_v6_remove_by_value(struct routing_table_v6 *table,
void *value);
=-=-=-=-=-=END API-=-=-=-=-=-=-=

I'm wondering from those who know this code well if the structure in
net/ip_fib.h and net/ip6_fib.h is suitable for what I want. Or, if I
should look elsewhere. Or, if I should in fact roll my own.

Thanks,
Jason
