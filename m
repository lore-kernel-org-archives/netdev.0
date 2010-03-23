From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Tue, 23 Mar 2010 21:10:22 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net>
 <4BA90F72.6010404@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BA90F72.6010404@linux-ipv6.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 24 Mar 2010, YOSHIFUJI Hideaki wrote:

> > In this case without conntrack, IPv6 would send an ICMPv6 message,
> > so in my opinion the transparent thing to do would be to still send
> > them. Of course only if reassembly is done on an end host.
> 
> Well, no.  conntrack should just forward even uncompleted fragments
> to next process (e.g. core ipv6 code), and then the core would send
> ICMP error back.  ICMP should be sent by the core ipv6 code according
> to decision of itself, not according to netfilter.

But what state could be associated by conntrack to the uncompleted 
fragments but the INVALID state? In consequence, in any sane setup, the 
uncompleted fragments will be dropped silently by a filter table rule
and no ICMP error message will be sent back.

Therefore I think iff the destination of the fragments is the host 
itself, then conntrack should generate an ICMP error message. But that 
error message must be processed by conntrack to set its state and then 
the fate of the generated packet can be decided by a rule.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
