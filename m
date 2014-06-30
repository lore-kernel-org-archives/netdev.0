From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Sporadic ESP payload corruption when using IPSec in NAT-T
 Transport Mode
Date: Mon, 30 Jun 2014 13:33:24 +0200
Message-ID: <20140630113324.GR32371@secunet.com>
References: <CALEwOppxvZ5F1-HeEnEEfe+GXs4=q+Eq+yL6W4xshemW8Wu9Ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>
To: Evan Gilman <evan@pagerduty.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALEwOppxvZ5F1-HeEnEEfe+GXs4=q+Eq+yL6W4xshemW8Wu9Ww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ccing netdev.

On Thu, Jun 26, 2014 at 02:12:30PM -0700, Evan Gilman wrote:
>    Hi all
>    We have a couple Ubuntu 10.04 hosts with kernel version 3.14.5 whi=
ch are
>    experiencing TCP payload corruption when using IPSec in NAT-T tran=
sport
>    mode. All are running under Xen at third party providers. When
>    communicating with other hosts using IPSec, we see that these corr=
upt TCP
>    PDUs are still being received by the remote listener, even though =
the TCP
>    checksum is invalid.
>    All other checksums (IPSec authentication header and IP checksum) =
are
>    good. So, we are thinking that corruption is happening during the =
ESP
>    encapsulation and decapsulation phase (IPSec required for reproduc=
tion).
>    The corruption occurs sporadically, and we have not found any one
>    payload/packet combination that will reliably trigger it, though w=
e can
>    typically reproduce it in less than 30 minutes. We can do it very =
simply
>    by reading from /dev/zero with dd and piping through netcat. It oc=
curs
>    whenever a 3.14.5 kernel is involved at either end of the conversa=
tion. I
>    can send captures to those who are interested. Does any of this so=
und
>    familiar?

I can't remember anyone reporting such problems, but maybe someone
else does.

>    Steps and observations so far:
>    - tcpdump running on both sender and receiver
>    - ESP looks sane on the outside. TCP payload corruption can be see=
n only
>    after decryption
>    - Once reproduced, you may see only one or two problem packets com=
e
>    through
>    - Sometimes corruption is witnessed on the wire (suspected encapsu=
lation
>    corruption)
>    - Sometimes corruption is _not_ witnessed on the wire, though the =
test
>    surfaces corruption (suspected decapsulation corruption)
>    - Corruption not witnessed over connections without a governing IP=
Sec
>    policy
>    - Corruption not witnessed after changing previously misbehaving h=
osts to
>    kernel version 2.6.32.
>    You can find the kernel config for the affected host
>    here:=A0[1]https://gist.github.com/evan2645/2c28d46e81d2b4c8f251
>    On another note, it seems the assumption that TCP payloads are saf=
e when
>    encapsulated by ESP, and therefore the checksum need not be verifi=
ed, is a
>    false one. It has certainly caused us a great deal of pain. Is the=
re a
>    significant reason for bypassing TCP checksum validation when usin=
g IPSec
>    Transport Mode?

We set the CHECKSUM_UNNECESSARY flag when IPsec transport mode is used =
in
combination with NAT because NAT might change the IP header what result=
s in
incorrect checksums. Bypassing the TCP checksum is one of the options
that are specified for this case in RFC 3948 section 3.1.2.

>    We are still trying to locate the exact spot in which the corrupti=
on is
>    occurring - any suggestions on how we could do that? We have not s=
een this
>    problem under Ubuntu 10.04 with kernel version 2.6.32. Thanks in a=
dvance!

There was a lot of development between v2.6.32 and v3.14.5, so it is ha=
rd
to say what is causing this problems. As a first step, it would be good
to know which kernel version introduced this problems.

>    --
>    evan
>=20
> References
>=20
>    Visible links
>    1. https://gist.github.com/evan2645/2c28d46e81d2b4c8f251
