From: "Fey Marcus" <Fey@iabg.de>
Subject: (usagi-users 04057) Re: ping6 is sent out from wrong interface
Date: Wed, 25 Jun 2008 09:51:05 +0200
Message-ID: <69A5E767EC979846826F566C7932A3F207233B5F@exchange03.iabg.de>
References: <4861ED72.6080100@miraclelinux.com>
Reply-To: usagi-users@ml.linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-2022-JP"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <usagi-users@linux-ipv6.org>
To: <usagi-users@ml.linux-ipv6.org>,
        =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?= <yoshfuji@linux-ipv6.org>
Return-path: <usagi-users-admin@ml.linux-ipv6.org>
In-Reply-To: <4861ED72.6080100@miraclelinux.com>
Content-Class: urn:content-classes:message
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@ml.linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@ml.linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@ml.linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@ml.linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi Naohiro,

>I'm not convinced yet.
>I don't think it's correct that kernel or ping6 arbitrarily 
>decides outgoing interface.
>
>Is this really an expected behaviour?
>Could you explain to me the reason of it, too?
>
>I think the behavior should be similar to IPv4.

It's due to routing.

Your routing table shows this:
---
    # route -A inet6
    Kernel IPv6 routing table
    Destination            Next Hop Flags Metric Ref    Use Iface
    2001:2c0:418:1::/64    *        U     256    0        0 eth0
    2001:2c0:418:2::/64    *        U     256    0        0 eth1
    fe80::/64              *        U     256    0        0 eth0
    fe80::/64              *        U     256    0        0 eth1
    ::::::
    2001:2c0:418:1::1/128  *        U     0      8        1 lo
    2001:2c0:418:2::2/128  *        U     0      5        1 lo
    ::::::
    ff00::/8               *        U     256    0        0 eth0
    ff00::/8               *        U     256    0        0 eth1
    #
---

...with eth0 being preferred over eth1 for multicast packets.

You could add a dedicated route for ff02::/16 to make the kernel output the packet via eth1.

Bye,

Marcus
-----------------------------------------
IABG mbH
Sitz der Gesellschaft: Ottobrunn, Registergericht: Amtsgericht Muenchen, HRB 5499
Geschaeftsfuehrung: Prof. Dr.-Ing. Rudolf F. Schwarz
Vorsitzender des Aufsichtsrats: General a. D. Wolfgang Altenburg
