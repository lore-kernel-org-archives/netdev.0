From: jamal <hadi@cyberus.ca>
Subject: Re: udp weirdness
Date: Sun, 29 Sep 2002 10:47:48 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209291044490.8253-200000@shell.cyberus.ca>
References: <20020927150412.GI30392@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-559023410-824023566-1033310868=:8253"
Cc: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matti Aarnio <matti.aarnio@zmailer.org>@shell.cyberus.ca@shell.cyberus.ca
In-Reply-To: <20020927150412.GI30392@mea-ext.zmailer.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---559023410-824023566-1033310868=:8253
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN
Content-Transfer-Encoding: QUOTED-PRINTABLE


Ok, understood. Actually we already seem to have enobufs being returned.

Eric,
Does the attached patch fix it? Not tested or even compiled.
Someone going to change the manpages?

cheers,
jamal

On Fri, 27 Sep 2002, Matti Aarnio wrote:

> On Fri, Sep 27, 2002 at 10:53:00AM -0400, jamal wrote:
> > On Fri, 27 Sep 2002, Eric Lemoine wrote:
> >
> > > I figured out that packets can be dropped in pfifo_fast_enqueue()
> > > [the default qdisc's enqueue func], even though the driver/kernel
> > > flow control has triggered.
> ...
> > What trigger do you suggest to wake up the process again?
> > A better idea maybe to return something to the socket so it can
> > manage things instead -- not sure what to return though that wouldnt
> > break some standard;
>
>
> "man sendto" error return codes:
>
>        ENOBUFS
>               The  output queue for a network interface was full.
>               This generally indicates  that  the  interface  has
>               stopped  sending,  but  may  be caused by transient
>               congestion.  (This cannot occur in  Linux,  packets
>               are just silently dropped when a device queue over=AD
>               flows.)
>
> > cheers,
> > jamal
>
> /Matti Aarnio
>

---559023410-824023566-1033310868=:8253
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="enobuf.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.GSO.4.30.0209291047480.8253@shell.cyberus.ca>
Content-Description: 
Content-Disposition: attachment; filename="enobuf.patch"

LS0tIGxpbnV4L25ldC9pcHY0L2lwX291dHB1dC5jCTIwMDIvMDkvMjkgMTA6
NDM6MTAJMS4xDQorKysgbGludXgvbmV0L2lwdjQvaXBfb3V0cHV0LmMJMjAw
Mi8wOS8yOSAxMDo0MzoxMA0KQEAgLTYwMyw4ICs2MDMsMTEgQEANCiAJCWVy
ciA9IE5GX0hPT0soUEZfSU5FVCwgTkZfSVBfTE9DQUxfT1VULCBza2IsIE5V
TEwsIA0KIAkJCSAgICAgIHNrYi0+ZHN0LT5kZXYsIG91dHB1dF9tYXliZV9y
ZXJvdXRlKTsNCiAJCWlmIChlcnIpIHsNCi0JCQlpZiAoZXJyID4gMCkNCi0J
CQkJZXJyID0gc2stPnByb3RpbmZvLmFmX2luZXQucmVjdmVyciA/IG5ldF94
bWl0X2Vycm5vKGVycikgOiAwOw0KKwkJCWlmIChlcnIgPiAwKSB7DQorCQkJ
CWVyciA9IG5ldF94bWl0X2Vycm5vKGVycik7DQorCQkJCWlmIChlcnIgJiYg
c2stPnByb3RpbmZvLmFmX2luZXQucmVjdmVycikNCisJCQkJICAgICAgIHNr
LT5wcm90aW5mby5hZl9pbmV0LnJlY3ZlcnIgPSBlcnI7DQorCQkJfQ0KIAkJ
CWlmIChlcnIpDQogCQkJCWdvdG8gZXJyb3I7DQogCQl9DQpAQCAtNzEzLDgg
KzcxNiwxMSBAQA0KIA0KIAllcnIgPSBORl9IT09LKFBGX0lORVQsIE5GX0lQ
X0xPQ0FMX09VVCwgc2tiLCBOVUxMLCBydC0+dS5kc3QuZGV2LA0KIAkJICAg
ICAgb3V0cHV0X21heWJlX3Jlcm91dGUpOw0KLQlpZiAoZXJyID4gMCkNCi0J
CWVyciA9IHNrLT5wcm90aW5mby5hZl9pbmV0LnJlY3ZlcnIgPyBuZXRfeG1p
dF9lcnJubyhlcnIpIDogMDsNCisJaWYgKGVyciA+IDApIHsNCisJCWVyciA9
IG5ldF94bWl0X2Vycm5vKGVycik7DQorCQlpZiAoZXJyICYmIHNrLT5wcm90
aW5mby5hZl9pbmV0LnJlY3ZlcnIpDQorCQkgICAgICAgCSBzay0+cHJvdGlu
Zm8uYWZfaW5ldC5yZWN2ZXJyID0gZXJyOw0KKwl9DQogCWlmIChlcnIpDQog
CQlnb3RvIGVycm9yOw0KIG91dDoNCg==

---559023410-824023566-1033310868=:8253--
