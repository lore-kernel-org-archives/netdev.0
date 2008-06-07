From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Sat, 7 Jun 2008 17:45:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806071742180.13503@bizon.gios.gov.pl>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net>
 <484AA5D5.10404@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1016760698-1212853508=:13503"
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <484AA5D5.10404@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1016760698-1212853508=:13503
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sat, 7 Jun 2008, Patrick McHardy wrote:

> Patrick McHardy wrote:
>> Chuck Ebbert wrote:
>>> Reported at https://bugzilla.redhat.com/show_bug.cgi?id=3D449315
>>>=20
>>> In find_appropriate_src():
>>>
>>>         hlist_for_each_entry_rcu(nat, n, &bysource[h], bysource) {
>>>                 ct =3D nat->ct;
>>>                 if (same_src(ct, tuple)) {
>>>=20
>>> Dereference of ct in same_src() causes the oops. This only seems to
>>> happen on heavily loaded firewall machines. Kernel 2.6.24.7 works.
>>>=20
>>> The reporter identifies commit 4d354c5782dc352cec187845d17eedc2c2bfcf67
>>> ("[NETFILTER]: nf_nat: use RCU for bysource hash") as a possible cause
>>> of the problem.
>>=20
>> We have a similar looking report, but that one also affects 2.6.24:
>>=20
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D10875
>>=20
>> Anyways, does this patch help? When reallocating storage
>> for a conntrack, it is replaced in the list before assigning
>> the nat->ct pointer.
>
>
> I'm afraid we also need this one on top - when reallocating
> an extension, we must not free the old storage since it may
> still be used in a RCU read side.

It does not help here: 2.6.26-rc5 plus two above patches still crashes.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1016760698-1212853508=:13503--
