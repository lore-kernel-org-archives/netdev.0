From: bert hubert <ahu@ds9a.nl>
Subject: automatic keying works! Re: off by one error in 3des cbc keying
Date: Wed, 13 Nov 2002 09:55:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021113085517.GA9134@outpost.ds9a.nl>
References: <20021112.143636.55033627.davem@redhat.com> <200211130109.EAA10034@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211130109.EAA10034@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2002 at 04:09:26AM +0300, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> >    The problem with expiration remains unsolved.
> 
> Patch #2. Bert, this is supposed to fix the first strange phenomenon
> in your experiment. But I still do not know what will happen after that.
> Please, check.

Resolves strange larvals, thanks. Patch #1 works fine but changes nothing
for linux-linux IPSEC, if both have the patch. Scenario I see now:

Initial setup is wonderful, 10.0.0.11 and 10.0.0.216 setup SAs.

At the soft expiration, both ends renegotiate and UPDATE their *incoming*
SA, using pk_sendupdate which calls pfkey_send_update in libipsec.

The outgoing SA however is updated using pk_sendadd which calls
pfkey_send_add, which Linux hates because there is already an SA there.

I changed it to call pfkey_sendupdate and then everything works as intended.
You spotted this problem earlier, by the way.

This brings us to the point that everything I try works. Key rollover is now
completely seamless. My patch to racoon is really ugly as it now also uses
UPDATE to add the initial outbound SA, I can improve it if you want?

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
