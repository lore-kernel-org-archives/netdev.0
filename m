From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 11:35:45 +0200
Message-ID: <49EEE4F1.4020705@cosmosbay.com>
References: <20090421230358.GA13660@hmsreliant.think-freely.org>	<20090422011214.GA18856@localhost.localdomain>	<49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54010 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950AbZDVJf4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:35:56 -0400
In-Reply-To: <20090422.020837.58106317.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 22 Apr 2009 07:15:15 +0200
>=20
>> Also, it seems some RFC4293 items are already handled, since commit =
d831666e
>> from Mitsuru Chinen. Check net/ipv4/proc.c, line 114
>>
>> /* Following RFC4293 items are displayed in /proc/net/netstat */
>> static const struct snmp_mib snmp4_ipextstats_list[] =3D {
>=20
> It is my understanding that after Mitsuru's patch, all RFC4293
> values are available in one way or another.

Hmm... I read RFC4293 and it mentions (3.2.3. IP Statistics Tables)

 (1) The HC counters and octet counters are also found at these points
       but have been left out for clarity.


(1) counters are :
 InReceives, InMcastPkts, OutMcastPkts, OutBcastPkts, OutTransmits

So RFC4293 tells corresponding Octets variables should be supported :

 InOctets, InMcastOctets, OutMcastOctets, OutBcastOctets, OutOctets

And I dont see them in /proc/net/snmp or /proc/net/netstat

Mitsuru added :

       SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
       SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
       SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
       SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
       SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
       SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),

And Neil adds : InOctets, OutOctets, InMcastOctets and OutMcastOctets

Neil, you forgot OutBcastOctets :)


