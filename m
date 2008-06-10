From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch] bondig - arp_interval with low value => Oops.
Date: Tue, 10 Jun 2008 15:30:06 -0700
Message-ID: <8135.1213137006@death>
References: <482C9E73.2040202@free.fr> <484EFDFC.3040206@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas 2P <nicolas.2p.debian@free.fr>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-reply-to: <484EFDFC.3040206@garzik.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:

>Nicolas 2P wrote:
>> When setting arp_interval parameter to a very low value, delta_in_ti=
cks
>> for next arp might become 0, causing an infinite loop.
>>
>> See http://bugzilla.kernel.org/show_bug.cgi?id=3D10680
>>
>> Same problem for miimon parameter already fixed, but fix might be
>> enhanced, by using msecs_to_jiffies() function.
>>
>> Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
>
>I don't see an ACK from Jay in my mbox?
>
>Certainly looks nicer than adding "? : 1" to each of the remaining two
>cases.

	This was accepted a couple of weeks ago; I had to fix a bug in
the patch, so I'd guess you didn't connect them:

commit 5ce0da8f0386b62345312ec8fed31303732f4220
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Sat May 17 21:10:07 2008 -0700

    bonding: Use msecs_to_jiffies, eliminate panic
   =20
        Convert bonding to use msecs_to_jiffies instead of doing the
    math.  For the ARP monitor, there was an underflow problem that cou=
ld
    result in an infinite loop.  The miimon already had that worked aro=
und,
    but this is cleaner.
   =20
        Originally by Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.=
fr>
    Jay Vosburgh corrected a math error in the original; Nicolas' origi=
nal
    commit message is:
   =20
    When setting arp_interval parameter to a very low value, delta_in_t=
icks
    for next arp might become 0, causing an infinite loop.
   =20
    See http://bugzilla.kernel.org/show_bug.cgi?id=3D10680
   =20
    Same problem for miimon parameter already fixed, but fix might be
    enhanced, by using msecs_to_jiffies() function.
   =20
    Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
