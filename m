From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Tue, 5 Aug 2008 00:04:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808050000360.29400@bizon.gios.gov.pl>
References: <20080803143730.7747e9a8@infradead.org>
 <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl>
 <20080804200058.GX28946@ZenIV.linux.org.uk> <20080804203021.GY28946@ZenIV.linux.org.uk>
 <Pine.LNX.4.64.0808042258370.29400@bizon.gios.gov.pl>
 <20080804215649.GZ28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1381134959-1217887491=:29400"
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:34518 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758093AbYHDWFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 18:05:08 -0400
In-Reply-To: <20080804215649.GZ28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1381134959-1217887491=:29400
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 4 Aug 2008, Al Viro wrote:

> On Mon, Aug 04, 2008 at 11:16:07PM +0200, Krzysztof Oledzki wrote:
>
>> Solves partially: no more WARNING, however entries are still missing &
>> duplicated:
>>
>> # sysctl -a 2>/dev/null|grep net.netfilter
>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>> net.netfilter.nf_conntrack_acct =3D 1
>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>> net.netfilter.nf_conntrack_acct =3D 1
>
> Very interesting.  Could you see at which point duplicates appear?  I.e.
> in which sequence do you get registrations, at least on the level of "thi=
s
> module is loaded first, no duplicates, this one comes after, etc."

All I need to do is to load a single "nf_conntrack" module.

> =09... ah, hell.  I see what's going on.  The trouble is in
> nf_conntrack_standalone; you get a table that has _both_ net.netfilter.* =
and
> net.nf_conntrack_max, which means that it's attached to unified tree at
> net; if we already have something with net.netfilter, you've got trouble =
-
> which entry net.netfilter will come from?

Indeed.

> _All_ this crap comes from lousy historical API; it's too much for this
> cycle, but for .28 I'm going to clean that mess up.  For now, split that
> table in two and register them separately.  I.e. register nf_ct_sysctl_ta=
ble[]
> at nf_net_netfilter_sysctl_path *and* remove the "netfilter" entry from
> nf_ct_netfilter_table[].

Will do. Thanks.

> I'm really going down right now; will follow up after I get some sleep...

Right. I'll try to prepare and test your ideas at that time. Thank you=20
again.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1381134959-1217887491=:29400--
