From: bert hubert <ahu@ds9a.nl>
Subject: Re: off by one error in 3des cbc keying
Date: Tue, 12 Nov 2002 20:06:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021112190655.GB26647@outpost.ds9a.nl>
References: <20021112151638.GA18488@outpost.ds9a.nl> <200211121529.SAA00584@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211121529.SAA00584@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 12, 2002 at 06:29:06PM +0300, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > > The problem with expiration remains unsolved. I still cannot reproduce this
> > > and cannot find a situation when kernel can create two larvals with one
> > > identity. :-( Searching.
> > 
> > Sure you saw that? I only saw the one larval in the output I sent you,
> 
> Sure, unless my sick cisco router corrupts mails. But I hope it is not
> so malicious. :-)
> 
> Joke aparts, of course, I did not see this, it exists for short time,
> you see one of them already grown to mature.

I've made a movie, the output of: 
while true; do date ; sudo download/kametools/setkey/setkey -D ; done > logs

Please find it attached.

This corresponds to:
20:01:43: INFO: isakmp.c:1689:isakmp_post_acquire(): IPsec-SA
request for 10.0.0.11 queued due to no phase1 found.
20:01:43: INFO: isakmp.c:794:isakmp_ph1begin_i(): initiate new
phase 1 negotiation: 10.0.0.216[500]<=>10.0.0.11[500]
20:01:43: INFO: isakmp.c:799:isakmp_ph1begin_i(): begin
Aggressive mode.
20:01:43: INFO: vendorid.c:128:check_vendorid(): received Vendor
ID: KAME/racoon
20:01:43: NOTIFY: oakley.c:2037:oakley_skeyid(): couldn't find
the proper pskey, try to get one by the peer's address.
20:01:43: INFO: isakmp.c:2417:log_ph1established(): ISAKMP-SA
established 10.0.0.216[500]-10.0.0.11[500]
spi:abf1baea48b9c16d:e422bce8c6b9f015
20:01:44: INFO: isakmp.c:938:isakmp_ph2begin_i(): initiate new
phase 2 negotiation: 10.0.0.216[0]<=>10.0.0.11[0]
20:01:44: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.11->10.0.0.216 spi=251701380(0xf00a884)
20:01:44: INFO: pfkey.c:1318:pk_recvadd(): IPsec-SA established:
ESP/Transport 10.0.0.216->10.0.0.11 spi=43499516(0x297bffc)

20:02:13: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 

Note how it changes very nearly atomically.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO

--5mCyUwZo2JvN/JJP
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="logs.bz2"
Content-Transfer-Encoding: base64

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

--5mCyUwZo2JvN/JJP--
