From: bert hubert <ahu@ds9a.nl>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 22:25:15 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021118212515.GB23680@outpost.ds9a.nl>
References: <20021118.122307.31019623.davem@redhat.com> <200211182032.XAA22666@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211182032.XAA22666@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 18, 2002 at 11:32:12PM +0300, kuznet@ms2.inr.ac.ru wrote:

> Bert, could you help woth testing? The patch adds timeing out policies.
> To test this it is necessary to configure racoon on one end as "passive",
> in this case it should update policy on demand and delete them in time.

Works. This also needs 'generate_policy on;', by the way. Racoon does not
however log if a policy times out. It normally does not because the remote
racoon keeps renewing the SA, which also renews the SP.

If the remote recoon is STOPped, the passive side nicely times out the SP,
although it does not tell the user this.

Wonderful stuff, I'm starting to like racoon a bit better.

2002-11-18 22:18:15: INFO: isakmp.c:890:isakmp_ph1begin_r(): respond new
phase 1 negotiation: 10.0.0.11[500]<=>10.0.0.216[500]
2002-11-18 22:18:15: INFO: isakmp.c:895:isakmp_ph1begin_r(): begin
Aggressive mode.
2002-11-18 22:18:16: INFO: isakmp.c:2417:log_ph1established(): ISAKMP-SA
established 10.0.0.11[500]-10.0.0.216[500]
spi:d65a99e9df6d6eea:4e21da098172dfda
2002-11-18 22:18:16: INFO: isakmp.c:1045:isakmp_ph2begin_r(): respond new
phase 2 negotiation: 10.0.0.11[0]<=>10.0.0.216[0]
2002-11-18 22:18:16: INFO: isakmp_quick.c:2014:get_proposal_r(): no policy
found, try to generate the policy : 10.0.0.216/32[0] 10.0.0.11/32[0]
proto=any dir=in2002-11-18 22:18:16: INFO: pfkey.c:1106:pk_recvupdate():
IPsec-SA established: ESP/Transport 10.0.0.216->10.0.0.11
spi=230551900(0xdbdf15c)
2002-11-18 22:18:16: INFO: pfkey.c:1318:pk_recvadd(): IPsec-SA established:
ESP/Transport 10.0.0.11->10.0.0.216 spi=264801187(0xfc88ba3)

2002-11-18 22:19:52: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 spi=230551900(0xdbdf15c)
2002-11-18 22:19:52: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.11->10.0.0.216 spi=264801187(0xfc88ba3)
2002-11-18 22:19:52: INFO: isakmp.c:1045:isakmp_ph2begin_r(): respond new
phase 2 negotiation: 10.0.0.11[0]<=>10.0.0.216[0]
2002-11-18 22:19:52: INFO: isakmp_quick.c:2014:get_proposal_r(): no policy
found, try to generate the policy : 10.0.0.216/32[0] 10.0.0.11/32[0]
proto=any dir=in2002-11-18 22:19:52: INFO: pfkey.c:1106:pk_recvupdate():
IPsec-SA established: ESP/Transport 10.0.0.216->10.0.0.11
spi=127223206(0x79545a6)
2002-11-18 22:19:52: INFO: pfkey.c:1318:pk_recvadd(): IPsec-SA established:
ESP/Transport 10.0.0.11->10.0.0.216 spi=140990312(0x8675768)
2002-11-18 22:20:16: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 spi=230551900(0xdbdf15c)
2002-11-18 22:20:16: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.11->10.0.0.216 spi=264801187(0xfc88ba3)



-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
