From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Tue, 25 May 2010 14:17:43 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1005251353370.20667@blackhole.kfki.hu>
References: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, 25 May 2010, Changli Gao wrote:

> iptables target SYNPROXY.
> 
> This patch implements an iptables target SYNPROXY, which works in the raw table
> of the PREROUTING chain, before conntracking system. Syncookies is used, so no
> new state is introduced into the conntracking system. In fact, until the first
> connection is established, conntracking system doesn't see any packets. So when
> there is a SYN-flood attack, conntracking system won't be busy on finding and
> deleting the un-assured ct.

My main problem with your target is that by using it, important and useful 
TCP options are lost: timestamp and SACK. That pushes back TCP by almost 
twenty years.

Here you reason for the target that it protects conntrack itself, but in 
the Kconfig text you write that it protects the servers behind the 
firewall. Both can be true, but if the real goal is to defend the servers 
then your target could simply send a faked ACK to complete the three way 
handshake and that way TCP would not be crippled (conntrack timeout 
should still be adjusted).

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
