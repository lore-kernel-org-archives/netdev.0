From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] nftables: use list_for_each_entry_safe_reverse to
 traversal commit_list in nf_tables_abort
Date: Thu, 10 Dec 2015 00:19:09 +0800
Message-ID: <CADvbK_fjSY3Z365=Bj5xcur-bXUqiXFqD_iPkxTJp_CJLZfZdg@mail.gmail.com>
References: <15bcb964221e1a9498e901417d020609cd5aac65.1449485287.git.lucien.xin@gmail.com>
	<20151209140330.GA1695@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, davem <davem@davemloft.net>,
	fw@strlen.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20151209140330.GA1695@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ok, the reproducer:
1.
#nft delete table foo
#nft add table foo
#nft list tables
#nft list table foo
#nft add chain foo bar
#nft add chain foo baz
#nft add chain foo bok
#nft list table foo

2. #nft -f panic.rules
------panic.rules-------
add rule foo bar ip saddr 127.0.0.1 accept
add rule foo bar ip saddr {192.168.1.2, 192.168.2.3} jump baz
add rule foo bar ip saddr {192.168.1.2, 192.168.2.3} jump bok

add rule foo baz ip saddr {192.168.1.2, 192.168.2.3} jump bok
add rule foo bok ip saddr {192.168.1.2, 192.168.2.3} jump baz

delete table foo
-------end-----------
the panic will happen 1/1
