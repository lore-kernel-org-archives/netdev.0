From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Fri, 23 Jul 2004 02:52:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41006150.9000702@trash.net>
References: <40F34740.5040100@trash.net>	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>	<20040712205037.573411c0.davem@redhat.com>	<40F4862D.3070802@trash.net>	<40F4AC8B.40706@trash.net>	<20040721143110.4ab944bf.davem@redhat.com>	<41004F76.1080807@trash.net> <20040722171752.341d2476.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030106070601060508090004"
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040722171752.341d2476.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030106070601060508090004
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
>>It needs to increment at slightly above 1Mhz, otherwise delay will
>>be zero after this division and everything will fall apart:
>>delay /= rdelay.
> 
> I see.  I know for a fact that sparc64 meets this criterion, and
> I'm pretty sure ppc64 does too.

I'm pretty sure x86, x86_64, alpha, sparc64, ppc64 and ia64 can
be used. I'm not sure if the frequency of all ppcs is high enough,
so I won't add support for them.

> We could bug check this in psched calibration, in fact I think
> we should.

Done by this patch. I used BUG_ON instead of just printing a warning
because using packet schedulers after this error will cause a division
by zero.

Regards
Patrick

--------------030106070601060508090004
Content-Type: application/octect-stream;
 name="psched-bug_on_invalid_cycles.diff"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="psched-bug_on_invalid_cycles.diff"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBkaWZmIC1OcnUgc3R5bGUgcGF0Y2gu
CiMKIyBDaGFuZ2VTZXQKIyAgIDIwMDQvMDcvMjMgMDI6NDU6MzkrMDI6MDAga2FiZXJAdHJh
c2gubmV0IAojICAgW1BLVF9TQ0hFRF06IEJVR19PTiBpbnZhbGlkIGRlbGF5IGZyb20gY3lj
bGUgY291bnRlciBpbiBwc2NoZWRfY2FsaWJyYXRlX2Nsb2NrCiMgICAKIyAgIFNpZ25lZC1v
ZmYtYnk6IFBhdHJpY2sgTWNIYXJkeSA8a2FiZXJAdHJhc2gubmV0PgojIAojIG5ldC9zY2hl
ZC9zY2hfYXBpLmMKIyAgIDIwMDQvMDcvMjMgMDI6NDU6MjcrMDI6MDAga2FiZXJAdHJhc2gu
bmV0ICsxIC0wCiMgICBbUEtUX1NDSEVEXTogQlVHX09OIGludmFsaWQgZGVsYXkgZnJvbSBj
eWNsZSBjb3VudGVyIGluIHBzY2hlZF9jYWxpYnJhdGVfY2xvY2sKIyAKZGlmZiAtTnJ1IGEv
bmV0L3NjaGVkL3NjaF9hcGkuYyBiL25ldC9zY2hlZC9zY2hfYXBpLmMKLS0tIGEvbmV0L3Nj
aGVkL3NjaF9hcGkuYwkyMDA0LTA3LTIzIDAyOjQ5OjI1ICswMjowMAorKysgYi9uZXQvc2No
ZWQvc2NoX2FwaS5jCTIwMDQtMDctMjMgMDI6NDk6MjUgKzAyOjAwCkBAIC0xMTU2LDYgKzEx
NTYsNyBAQAogCWlmIChyZGVsYXkgPiBkZWxheSkKIAkJcmV0dXJuIC0xOwogCWRlbGF5IC89
IHJkZWxheTsKKwlCVUdfT04oZGVsYXkgPT0gMCk7CiAJcHNjaGVkX3RpY2tfcGVyX3VzID0g
ZGVsYXk7CiAJd2hpbGUgKChkZWxheT4+PTEpICE9IDApCiAJCXBzY2hlZF9jbG9ja19zY2Fs
ZSsrOwo=
--------------030106070601060508090004--
