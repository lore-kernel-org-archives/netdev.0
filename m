From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Fri, 1 Dec 2006 13:35:24 -0500
Message-ID: <43e72e890612011035hf24aeb6wd20f8e93d2238c68@mail.gmail.com>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
	 <200611291612.33448.mb@bu3sch.de>
	 <20061129152407.GB5412@devicescape.com>
	 <200611291638.56759.mb@bu3sch.de>
	 <20061129160328.GA22602@devicescape.com>
	 <20061129121312.4cfc254f@freekitty>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4314_25958071.1164998124779"
Cc: "David Kimdon" <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net,
	"Nick Kossifidis" <mickflemm@gmail.com>,
	"Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:43650 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1031706AbWLASf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 13:35:29 -0500
Received: by wr-out-0506.google.com with SMTP id i7so1284384wra
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 10:35:28 -0800 (PST)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20061129121312.4cfc254f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_4314_25958071.1164998124779
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 11/29/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Wed, 29 Nov 2006 08:03:28 -0800
> David Kimdon <david.kimdon@devicescape.com> wrote:
>
> > On Wed, Nov 29, 2006 at 04:38:56PM +0100, Michael Buesch wrote:
> > > On Wednesday 29 November 2006 16:24, David Kimdon wrote:
> > > > On Wed, Nov 29, 2006 at 04:12:33PM +0100, Michael Buesch wrote:
> > > > > On Wednesday 29 November 2006 15:34, Nick Kossifidis wrote:
> > > > Why do you say that?
> > > >
> > > > There is absolutely no reason why dadwifi can't be merged into the
> > > > mainline once the hal issue is resolved.
> > >
> > > Last time we talked about that stuff, it was decided that
> > > we don't want a HAL... See archives.
> >
> > To be clear, that is all part of the hal issue that needs to be
> > resolved.  Removing the hal abstraction is not difficult for an
> > interested party once source for the hal is available.  The next step
> > in such an effort would be to add an open hal to dadwifi, IMO.
> >
>
> Isn't it obvious. Planning from goal through intermediate steps gives:
>
> 0 - today (raw materials)
>         * softmac stack: d80211
>         * open hal: ar5k
>         * glue layer: dadwifi
>
> 1- put pieces together
>         * d80211 + dadwifi + ar5k

The problem actually is that ar5k port to Linux Nick wrote currently
only works with an older version of madwifi (svn 1142) which itself
needs some patching and that dadwifi is based on the latest and
greatest madwifi source base. So a d80211 + dadwifi + ar5k will only
work if Nick's ar5k port is extended to support the latest
madwifi/dadwifi. I haven't had time yet to determine the exact
requirements on Nick's ported openhal to work with dadwifi but that
should be our focus for now in parallel with completing dadwifi.

For those curious the attached patch fixes madwifi 1142 release for
use with kernels >= 2.6.18-rc1. Add Nick's ar5k port to linux and
you'll have a Free driver ready. Since I see the mb's openhal git
repos is down here is a link for it as I checked it out on 2006-08-03:

http://www.kernel.org/pub/linux/kernel/people/mcgrof/openhal-2006-08-03.tar.gz

(give it sometime to sync)

To make things easier for development I'd like to suggest a few madwif
ibranches created:

* madwifi-1152-openhal: based on madwifi-1152, patched with my patch,
added openhal, old hal removed. Working free solution. Should exist
just as a reference and to allow users to checkout a working free
alternative in the mean time.

* madwifi-dadwifi-openal: based on the latest dadwifi with the
openhal, old hal removed. As dadwifi gets updated you can pull updates
to this branch. As the openhal advances you can make updates to the
openhal here.

Once we get dadwifi+openhal branch working I believe it should become
the trunk of madwifi.

Lastly, if anyone needs access to atheros hardware for development of
this driver or the openhal please let me know and you will get access
to a lot of nodes for development.

  Luis

------=_Part_4314_25958071.1164998124779
Content-Type: text/x-patch; name=madwifi-1142-fixed-2.6.18-rc1.diff;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ev6x0g53
Content-Disposition: attachment; filename="madwifi-1142-fixed-2.6.18-rc1.diff"

ZGlmZiAtTmF1cnAgbWFkd2lmaS1vcGVuaGFsL2F0aC9pZl9hdGguYyBtYWR3aWZpLW9wZW5oYWwt
Zml4ZWQvYXRoL2lmX2F0aC5jCi0tLSBtYWR3aWZpLW9wZW5oYWwvYXRoL2lmX2F0aC5jCTIwMDUt
MDYtMjQgMDY6NDE6MjIuMDAwMDAwMDAwIC0wNDAwCisrKyBtYWR3aWZpLW9wZW5oYWwtZml4ZWQv
YXRoL2lmX2F0aC5jCTIwMDYtMDgtMDQgMTQ6NDk6MzguMDAwMDAwMDAwIC0wNDAwCkBAIC0yNDUs
MTMgKzI0NSwyMCBAQCBlbnVtIHsKICNlbmRpZgogCiBzdGF0aWMJaW50IGNvdW50cnljb2RlID0g
LTE7Ci1NT0RVTEVfUEFSTShjb3VudHJ5Y29kZSwgImkiKTsKLU1PRFVMRV9QQVJNX0RFU0MoY291
bnRyeWNvZGUsICJPdmVycmlkZSBkZWZhdWx0IGNvdW50cnkgY29kZSIpOwogc3RhdGljCWludCBv
dXRkb29yID0gLTE7Ci1NT0RVTEVfUEFSTShvdXRkb29yLCAiaSIpOwotTU9EVUxFX1BBUk1fREVT
QyhvdXRkb29yLCAiRW5hYmxlL2Rpc2FibGUgb3V0ZG9vciB1c2UiKTsKIHN0YXRpYwlpbnQgeGNo
YW5tb2RlID0gLTE7CisjaWYgKExJTlVYX1ZFUlNJT05fQ09ERSA8IEtFUk5FTF9WRVJTSU9OKDIs
NSw1MikpCitNT0RVTEVfUEFSTShjb3VudHJ5Y29kZSwgImkiKTsKK01PRFVMRV9QQVJNKG91dGRv
b3IsICJpIik7CiBNT0RVTEVfUEFSTSh4Y2hhbm1vZGUsICJpIik7CisjZWxzZQorI2luY2x1ZGUg
PGxpbnV4L21vZHVsZXBhcmFtLmg+Cittb2R1bGVfcGFyYW0oY291bnRyeWNvZGUsIGludCwgMCk7
Cittb2R1bGVfcGFyYW0ob3V0ZG9vciwgaW50LCAwKTsKK21vZHVsZV9wYXJhbSh4Y2hhbm1vZGUs
IGludCwgMCk7CisjZW5kaWYKK01PRFVMRV9QQVJNX0RFU0MoY291bnRyeWNvZGUsICJPdmVycmlk
ZSBkZWZhdWx0IGNvdW50cnkgY29kZSIpOworTU9EVUxFX1BBUk1fREVTQyhvdXRkb29yLCAiRW5h
YmxlL2Rpc2FibGUgb3V0ZG9vciB1c2UiKTsKIE1PRFVMRV9QQVJNX0RFU0MoeGNoYW5tb2RlLCAi
RW5hYmxlL2Rpc2FibGUgZXh0ZW5kZWQgY2hhbm5lbCBtb2RlIik7CiAKIGludApkaWZmIC1OYXVy
cCBtYWR3aWZpLW9wZW5oYWwvb3BlbmhhbC9hcjV4eHguaCBtYWR3aWZpLW9wZW5oYWwtZml4ZWQv
b3BlbmhhbC9hcjV4eHguaAotLS0gbWFkd2lmaS1vcGVuaGFsL29wZW5oYWwvYXI1eHh4LmgJMjAw
Ni0wOC0wMyAxNToyNDozMC4wMDAwMDAwMDAgLTA0MDAKKysrIG1hZHdpZmktb3BlbmhhbC1maXhl
ZC9vcGVuaGFsL2FyNXh4eC5oCTIwMDYtMDgtMDQgMTQ6NDI6MzcuMDAwMDAwMDAwIC0wNDAwCkBA
IC0xNDI1LDcgKzE0MjUsNyBAQCBzdHJ1Y3QgYXI1a19zcmV2X25hbWUgewogCXsgIjUxMTEiLAlB
UjVLX1ZFUlNJT05fUkFELAlBUjVLX1NSRVZfUkFEXzUxMTEgfSwJXAogCXsgIjIxMTEiLAlBUjVL
X1ZFUlNJT05fUkFELAlBUjVLX1NSRVZfUkFEXzIxMTEgfSwJXAogCXsgIjUxMTIiLAlBUjVLX1ZF
UlNJT05fUkFELAlBUjVLX1NSRVZfUkFEXzUxMTIgfSwJXAotCXsgIjUxMTJhIiwJQVI1S19WRVJT
SU9OX1JBRCwJQVI1S19TUkVWX1JBRF81MTEyQSB9LAlcIAorCXsgIjUxMTJhIiwJQVI1S19WRVJT
SU9OX1JBRCwJQVI1S19TUkVWX1JBRF81MTEyQSB9LAlcCiAJeyAiMjExMiIsCUFSNUtfVkVSU0lP
Tl9SQUQsCUFSNUtfU1JFVl9SQURfMjExMiB9LAlcCiAJeyAiMjExMmEiLAlBUjVLX1ZFUlNJT05f
UkFELAlBUjVLX1NSRVZfUkFEXzIxMTJBIH0sCVwKIAl7ICJ4eHh4IiwJQVI1S19WRVJTSU9OX1JB
RCwJQVI1S19TUkVWX1VOS05PV04gfQlcCg==
------=_Part_4314_25958071.1164998124779--
