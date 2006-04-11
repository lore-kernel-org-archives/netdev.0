From: "George P Nychis" <gnychis@cmu.edu>
Subject: Re: created new q_disc, inserted module,
	tc tells me unknown qdisc
Date: Tue, 11 Apr 2006 15:26:50 -0400 (EDT)
Message-ID: <3568.128.2.140.234.1144783610.squirrel@128.2.140.234>
References: <1707.128.2.140.234.1144719699.squirrel@128.2.140.234>
	<20060411111644.59573edc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <20060411111644.59573edc@localhost.localdomain>
To: "Stephen Hemminger" <shemminger@osdl.org>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

> On Mon, 10 Apr 2006 21:41:39 -0400 (EDT) "George P Nychis"
> <gnychis@cmu.edu> wrote:
>=20
>> Hi,
>>=20
>> I am trying to install a proprietary qdisc made for research, it is no=
t
>> publically released yet, however its been used several times so i know
>> it works.
>>=20
>> The files included are: q_xcp.c: static int xcp_parse_opt() static int
>> xcp_print_opt() static int xcp_print_xstats() struct qdisc_util xcp_ut=
il
>> =3D { "NULL", "xcp" ..... };
>>=20
>> sch_xcp.c: static int xcp_enqueue() static int xcp_requeue() static st=
ruct
>> sk_buff * xcp_dequeue() .... .... struct Qdisc_ops xcp_qdisc_ops =3D{
>> NULL,NULL,"xcp",.... };
>>=20
>> printk(KERN_INFO "XCP qdisc module loaded.\n"); return
>> register_qdisc(&xcp_qdisc_ops);
>>=20
>>=20
>> So, i make everything successfully, it creates q_xcp.so and copies it
>> to /usr/lib and sch_xcp.o which it copies to /lib/modules/... so then =
I
>> "insmod sch_xcp" and i see in dmesg: "XCP qdisc module loaded."
>>=20
>> I then try: "tc qdisc add dev eth0 root xcp capacity 10Mbit limit 500"
>> and get: "Unknown qdisc "xcp", hence option "capacity" is unparsable"
>>=20
>> So then I read the INSTALL further to find some sort of solution and i=
t
>> mentions: This again assumes "tc" version is 2.4.7.  If your "tc" is a
>> different version, download the iproute2 source code, and edit Makefil=
e
>> to point "TC_INCLUDE" to "-I..../iproute2/include -I..../iproute2/tc"
>>=20
>> So, i did that, and i recompiled the q_xcp.so: lanthanum-ini src-1.0.1=
 #
>> make q_xcp.so cc -O2 -fPIC
>> -I/var/tmp/portage/iproute2-2.6.11.20050310-r1/work/iproute2-2.6.11/in=
c
>> lude/
>> -I/var/tmp/portage/iproute2-2.6.11.20050310-r1/work/iproute2-2.6.11/tc=
_
>> include -o q_xcp.o -c q_xcp.c ld -shared -o q_xcp.so q_xcp.o rm -f
>> q_xcp.o
>>=20
>> But i still get the same error.... so then my very final last effort
>> was to move q_xcp.c to my iproute2 source code tc/ directory and added
>> this to the makefile: TCMODULES +=3D q_xcp.o
>>=20
>> Then I compiled tc, and i check tc to see if the xcp qdisc functions
>> were loaded: lanthanum-ini tc # nm tc | grep xcp 080531ec t xcp_parse_=
opt
>>  080533e0 t xcp_print_opt 08053426 t xcp_print_xstats 08070cc0 D xcp_u=
til
>>=20
>>=20
>> And finally: lanthanum-ini tc # ./tc qdisc add dev ath0 root xcp
>> capacity 54Mbit limit 500 Unknown qdisc "xcp", hence option "capacity"
>> is unparsable
>>=20
>>=20
>> I have no clue :(  I figured that putting the .so into /usr/lib would
>> have been enough.  Sorry for the long e-mail, I hope someone can help,
>> and thank you for your time even if you don't know the solution but
>> read this :)
>>=20
>> - George
>>=20
>=20
> The .so needs to go in /usr/lib/tc (assuming you are running relatively
> recent version of iproute2 tools).
>=20
> Read source to tc.c where it calls dlopen.
>=20
>=20

Still didn't seem to solve the problem :\

In my tc.c i have:
   snprintf(buf, sizeof(buf), "/usr/lib/tc/q_%s.so", str);

Also:
lanthanum-ini tc # ls /usr/lib/tc
experimental.dist  normal.dist  pareto.dist  paretonormal.dist  q_netem.s=
o  q_xcp.so

And finally:
lanthanum-ini tc # tc qdisc add dev ath0 root xcp capacity 54Mbit limit 5=
00
Unknown qdisc "xcp", hence option "capacity" is unparsable

Maybe i should add debugging in tc.c and see if it sees the .so and fails=
 to load it or something.

Any other suggestions?

Thanks for all the responses,
George
