From: jordi@baylina.org
Subject: Idea for packet classification.
Date: Tue, 27 Sep 2005 18:17:59 +0200
Message-ID: <20050927161759.20229.qmail__15317.4418294386$1127838249$gmane$org@powy.masterasp.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The idea is to create a set of iptables TARGETS that classifies the packe=
ts.=20

When a packet is classified, a classification / Values is associated with=
=20
the packet.=20

This classifications can then be used on an iptable filter rule, in a=20
routing table selection rule or in a tc classification filter.=20


For example:=20

#iptables =E2=80=93A INPUT =E2=80=93j CLS user --classifier tcfilter --fi=
ltername u32=20
=E2=80=A6
#iptables =E2=80=93A INPUT =E2=80=93j CLS quota_plan --classifier hash --=
table=20
user_to_quota --input cls user
#iptables =E2=80=93A INPUT =E2=80=93j CLS tos --classifier tos=20

#iptables =E2=80=93A FORWARD =E2=80=93p tcp =E2=80=93port 5343 =E2=80=93c=
ls quota_plan=3D1 =E2=80=93j DROP=20


So in this example when a packet arrives, the source address is taken and=
=20
translated directly to a user, and the packet is marked with the userid.=20
I.e. The packed has an associated classification user =3D 23=20

In the second line a hash table classifies the packet. The user is taken=20
from input and a quota plan is taken as an output.=20

So after the second rule, the packet has associated 2 classifications:
	user=3D23
	quota_plan=3D2=20

The 3rd line classifies the packet by TOS so the packet has 3=20
classifications
	User=3D23
	Quota_plan=3D2
	Tos=3D0=20

Once a packet is classified, those classifications can be used in a filte=
r=20
rule or can be used in a routing rule or in a traffic shaping queue=20
classification.=20

A packet can have many classifications
Those classifications can be used any time in the packet live.=20

In the 4th line in th example, the rule drops all tcp packets with port 5=
343=20
and had been classified as quota_plan=20

The 1st line in the rule uses a tc filter wrapper to classify the packet.=
=20

This idea would be an extesion of the MARK target.=20

I am planning to make a patch to implement a couple of functions to inser=
t=20
classifications to the sk_buff structure and to  consult classifications =
of=20
a sk_buff.
Do you believe that it is interesting or are you planning to do packet=20
classifications in another way and doing that I would lose the time.=20

Thank you,=20

Jordi=20
