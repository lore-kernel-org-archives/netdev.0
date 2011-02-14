From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Mon, 14 Feb 2011 17:24:37 +0100
Message-ID: <4D595745.7070505@trash.net>
References: <4D594313.4050009@redhat.com>	 <1297696283.2996.33.camel@edumazet-laptop>	 <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr> <1297698641.2996.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010108030604040701060609"
Cc: Jan Engelhardt <jengelh@medozas.de>, Avi Kivity <avi@redhat.com>,
	netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56030 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073Ab1BNQYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 11:24:39 -0500
In-Reply-To: <1297698641.2996.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010108030604040701060609
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Am 14.02.2011 16:50, schrieb Eric Dumazet:
> Le lundi 14 février 2011 à 16:18 +0100, Jan Engelhardt a écrit :
>> On Monday 2011-02-14 16:11, Eric Dumazet wrote:
>>
>>> Le lundi 14 février 2011 à 16:58 +0200, Avi Kivity a écrit :
>>>> We see severe memory corruption in kvm while used in conjunction with 
>>>> bridge/netfilter.  Enabling slab debugging points the finger at a 
>>>> netfilter chain invoked from the bridge code.
>>>>
>>>> Can someone take a look?
>>>>
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=27052
>>
>> Maybe looks familiar to https://lkml.org/lkml/2011/2/3/147
> 
> Are you sure Jan ?
> 
> IMHO it looks like in your case, a NULL ->hook() is called, from
> nf_iterate()
> 
> BTW, list_for_each_continue_rcu() really should be converted to 
> list_for_each_entry_continue_rcu()
> 
> This is a bit ugly :
> 
> list_for_each_continue_rcu(*i, head) {
> 	struct nf_hook_ops *elem = (struct nf_hook_ops *)*i;
> 
> Also, I wonder if RCU rules are respected in nf_iterate().
> For example this line is really suspicious :
> 
> *i = (*i)->prev;

Yeah, that definitely looks wrong. How about this instead?


--------------010108030604040701060609
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="x"

ZGlmZiAtLWdpdCBhL25ldC9uZXRmaWx0ZXIvY29yZS5jIGIvbmV0L25ldGZpbHRlci9jb3Jl
LmMKaW5kZXggMWUwMGJmNy4uODk5YjcxYyAxMDA2NDQKLS0tIGEvbmV0L25ldGZpbHRlci9j
b3JlLmMKKysrIGIvbmV0L25ldGZpbHRlci9jb3JlLmMKQEAgLTEzMyw2ICsxMzMsNyBAQCB1
bnNpZ25lZCBpbnQgbmZfaXRlcmF0ZShzdHJ1Y3QgbGlzdF9oZWFkICpoZWFkLAogCiAJCS8q
IE9wdGltaXphdGlvbjogd2UgZG9uJ3QgbmVlZCB0byBob2xkIG1vZHVsZQogCQkgICByZWZl
cmVuY2UgaGVyZSwgc2luY2UgZnVuY3Rpb24gY2FuJ3Qgc2xlZXAuIC0tUlIgKi8KK3JlcGVh
dDoKIAkJdmVyZGljdCA9IGVsZW0tPmhvb2soaG9vaywgc2tiLCBpbmRldiwgb3V0ZGV2LCBv
a2ZuKTsKIAkJaWYgKHZlcmRpY3QgIT0gTkZfQUNDRVBUKSB7CiAjaWZkZWYgQ09ORklHX05F
VEZJTFRFUl9ERUJVRwpAQCAtMTQ1LDcgKzE0Niw3IEBAIHVuc2lnbmVkIGludCBuZl9pdGVy
YXRlKHN0cnVjdCBsaXN0X2hlYWQgKmhlYWQsCiAjZW5kaWYKIAkJCWlmICh2ZXJkaWN0ICE9
IE5GX1JFUEVBVCkKIAkJCQlyZXR1cm4gdmVyZGljdDsKLQkJCSppID0gKCppKS0+cHJldjsK
KwkJCWdvdG8gcmVwZWF0OwogCQl9CiAJfQogCXJldHVybiBORl9BQ0NFUFQ7Cg==
--------------010108030604040701060609--
