From: bert hubert <ahu@ds9a.nl>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Wed, 13 Nov 2002 23:03:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021113220311.GA29358@outpost.ds9a.nl>
References: <20021113085517.GA9134@outpost.ds9a.nl> <200211132046.XAA12943@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211132046.XAA12943@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2002 at 11:46:40PM +0300, kuznet@ms2.inr.ac.ru wrote:

> We traced all this today. It was not true reason of bad behaviour,
> real mistake was in absolutely different place. The patch (not incremental
> wrt patch of yesterday, so backout that one).

Done. http://ds9a.nl/ipsec now contains patches:

[TXT] 01-bypass-connect.diff        11-Nov-2002 08:59    16k  
[TXT] 02-udp-bypass.diff            12-Nov-2002 15:14     2k  
[TXT] 03-interop-breaks-compat.diff 13-Nov-2002 08:25     3k  
[TXT] 04-larval-2.diff              13-Nov-2002 21:53     5k  

When applied together, it now *really* works as intended :-)

> No, really. The trace showed another problem: one of them looks like
> a bug in racoon namely, after SA internal to IKE expires racoon
> does not initiate new connection to peer when some real kernel

I now see a proper soft expire, new SAs being setup, old SAs in state 'dying',
and traffic flowing nicely. Even with soft expire and no traffic, I see a
new SA being negotiated.

Until the old SAs die, I see linux sending with the old SPI, is that right?

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
