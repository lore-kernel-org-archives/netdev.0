From: prmarino1@gmail.com
Subject: Re: Configure ICMP error source address
Date: Fri, 08 Jan 2016 22:57:08 -0500
Message-ID: <20160109035708.5251154.82433.21820@gmail.com>
References: <568F8207.9040305@heinlein-support.de>
 <20160108152448.5251154.50977.21786@gmail.com>
 <568FDFBF.3010300@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Robert Sander <r.sander@heinlein-support.de>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <568FDFBF.3010300@stressinduktion.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=C2=A0The reason why is in the kernel documentation distributed with th=
e source code.
=E2=80=8EIts not all immediately obvious why and where the kernel does =
this unless you were involved in the original debates about it. The pro=
blems with binding a public ip address to a loopback address are more r=
ecently is partialy selinux but mostly of it is because of how routing =
changed when iproute2 was introduced in the 2.2 kernel (if I remember t=
he versions correctly it was so long ago). The reason is security, many=
 processes bind to the loopback interface for IPC and just grab the fir=
st address on the first lo device they find, some of the developers of =
the applications weren't even aware they were doing it because in some =
cases it was C libraries several layers deep doing it because odd loopb=
ack addresses were common on UNIX ( I remember an AIX admin back in the=
 early 90's telling me I should always use addresses like 127.1.0.2 on =
the loopback because it was valid made it harder for script kiddies to =
attack processes ). This was fine when additional addresses would need =
additional alias on the interface for ifconfig (lo:1 for example) but w=
ith iproute2 you could now assign multiple ip addresses to an interface=
 without creating an alias (commonly seen on the keepalived mailing lis=
t "why doesn't my VIP show up in ifconfig?")
So there was a decision made to declare all subnets assigned to the loo=
pback interface as unroutable to prevent a lot of very common security =
holes that were being seen in the wild.

That said you can make it work but you have to do a lot of things you s=
hould never do on a firewall like turn off selinux.=E2=80=8E Or you can=
 simply use the dummy driver and bind your public IP's to that and the =
problems magically go away. And it makes a lot of sense why else would =
there be a need for the dummy network driver?


=C2=A0 Original Message =C2=A0
=46rom: Hannes Frederic Sowa
Sent: Friday, January 8, 2016 11:11
To: prmarino1@gmail.com; Robert Sander; netfilter@vger.kernel.org; netd=
ev@vger.kernel.org
Subject: Re: Configure ICMP error source address

On 08.01.2016 16:24, prmarino1@gmail.com wrote:
> Don't put a public address on a lo device use a dummy eth interface i=
nstead=E2=80=8E. Any IP address and it's subnet assigned to a lo device=
 is marked as a marcian address and the traffic is dropped if it tries =
to leave the lo device.

O_o

> I know that there is som old documentation out there (for example qua=
gga's documentation) that says you can do it =E2=80=8Ebut it's been wro=
ng since the 2.4 version off the kernel.
> Linux treats the lo device differently that what routers call a loopb=
ack device. The dummy driver is the linux equivalent of what routers ca=
ll a loopback device.

What you write seems odd to me, we don't treat lo devices differently t=
o=20
dummy devices in respect if you bind a public ip address on it.

Bye,
Hannes



