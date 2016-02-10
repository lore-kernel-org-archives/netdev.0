From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: kernel BUG at net/netfilter/nf_nat_core.c:395
Date: Wed, 10 Feb 2016 19:34:40 +0200
Message-ID: <3938975.V1JGlkzPkU@spock>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

With 4.4.1 I've got BUG_ON() triggered in net/netfilter/nf_nat_core.c:395, 
nf_nat_setup_info(), today on my home router.

Here is full trace got via netconsole: [1]

I perform LAN NATting using nftables like this:

===
table ip nat {
        chain prerouting {
                type nat hook prerouting priority -150;
        }
 
        chain postrouting {
                type nat hook postrouting priority -150;
 
                oifname enp2s0 ip saddr 172.17.28.0/24 counter snat 1.2.3.4
                oifname enp2s0 ip saddr 172.17.29.0/24 counter snat 1.2.3.4
                oifname enp2s0 ip saddr 172.17.31.0/24 counter snat 1.2.3.4
                oifname enp2s0 ip saddr 172.17.35.0/24 counter snat 1.2.3.4
                oifname enp2s0 ip saddr 172.17.37.0/24 counter snat 1.2.3.4
                oifname tun0 ip saddr 172.17.28.0/24 counter masquerade
                oifname tun0 ip saddr 172.17.29.0/24 counter masquerade
                oifname tinc0 ip saddr 172.17.28.0/24 counter masquerade
                oifname tinc0 ip saddr 172.17.29.0/24 counter masquerade
        }
}
===

Traffic filtering is done via nftables as well.

Ideas? What could I do to debug the issue better?

[1] https://gist.github.com/bbb3712f40a7753537fe
