From: "Shekhar Kshirsagar" <shekhark@juniper.net>
Subject: RE: 2.6 IPSec Throughput puzzle
Date: Wed, 29 Dec 2004 15:50:34 -0800
Message-ID: <EF311E6F9B0B0848A49ED20B06E9CB27031FDE7A@gluon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8bit
Cc: "bert hubert" <ahu@ds9a.nl>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Networking Team" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I played with oprofile for a while, and it seems that in case of null
encryption, scatterwalk related code takes most of the cpu cycles.

Tunnel mode ESP with null-encryption/sha1 (throughput 51MBits/sec),
following are the top contenders:

samples  %        symbol name
5794     18.9192  crypt
4812     15.7127  scatterwalk_done
3354     10.9518  sha1_transform
2530      8.2612  page_address
2469      8.0620  scatterwalk_copychunks
2458      8.0261  scatterwalk_map
1440      4.7020  kmap_atomic
1360      4.4408  default_idle
1077      3.5167  scatterwalk_whichbuf
930       3.0367  kunmap_atomic
731       2.3869  handle_IRQ_event
676       2.2073  ecb_process
381       1.2441  ide_intr

Tunnel mode ESP with aes/sha1 (throughput 114MBits/sec), following are
the top contenders:
samples  %        symbol name
9056     29.6122  default_idle
7245     23.6904  sha1_transform
3933     12.8605  aes_enc_blk
931       3.0443  cbc_process
792       2.5898  crypt
716       2.3412  scatterwalk_done
519       1.6971  handle_IRQ_event
433       1.4159  sha1_update
412       1.3472  pskb_expand_head
380       1.2426  csum_partial
373       1.2197  page_address
368       1.2033  scatterwalk_map
345       1.1281  scatterwalk_copychunks


Is there any place where I can find documentation about what exactly
scatterwalk does?

Thanks,
Shekhar
> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of bert hubert
> Sent: Wednesday, December 29, 2004 4:12 AM
> To: Shekhar Kshirsagar
> Cc: Networking Team
> Subject: Re: 2.6 IPSec Throughput puzzle
> 
> On Tue, Dec 28, 2004 at 07:17:26PM -0800, Shekhar Kshirsagar wrote:
> 
> > I'm really puzzled with the performance results I'm getting. The
> > performance drop with AH seems high, but worst is performance drop
with
> > null-esp in transport mode. Another strange observation is that DES
> > throughput is greater than null encryption throughput.
> 
> Thanks for doing these benchmarks! I did some myself some time ago,
but my
> hardware isn't representative of anything (consisting of a pentium pro
200
> against a P3 1GHz).
> 
> > Throughput without IPSec	: 936 MBits/s ( 25% CPU Util)
> > Transport mode AH - SHA1      : 398 MBits/s (100% CPU Util)
> > Transport mode ESP - null/SHA1:  62 MBits/s (100% CPU Util)
> > Transport mode ESP - des/SHA1 : 111 MBits/s (100% CPU Util)
> > Transport mode ESP - 3des/SHA1:  54 MBits/s (100% CPU Util)
> > Transport mode ESP - aes/SHA1 : 192 MBits/s (100% CPU Util)
> >
> > Do these numbers sound reasonable?
> > (I don't have any iptable rules)
> 
> It is very easy to use oprofile these days, I suggest you profile for
a
> bit,
> should easily tell you what the culprit is. 62MBit/s sounds very low.
> 
> Good luck!
> 
> --
> http://www.PowerDNS.com      Open source, database driven DNS Software
> http://lartc.org           Linux Advanced Routing & Traffic Control
HOWTO
> 
