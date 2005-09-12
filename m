From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: 2.613: network write socket problems
Date: Mon, 12 Sep 2005 17:39:45 +0200
Message-ID: <200509121739.46172.bernd.schubert__36125.5726930269$1126539873$gmane$org@pci.uni-heidelberg.de>
Reply-To: bernd-schubert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

on last Friday  we switched on our server to 2.6.13 and today we are=20
experiencing problems with our nfs clients.
In particular I'm talking about the unfs3 daemon, not the kernel nfs daem=
on.=20
Both are running on the server but on different ports, of course.  Both a=
re=20
also serving to the same clients, but different directories.

Today it already several times happend that the unfs3 daemon stalled. Eth=
ereal=20
showed no network packages on the unfs3 daemon port during this time.=20
A strace to the proc-id of the daemon clearly shows that *some* writes to=
 some=20
network sockets will take ages to finish

write(37, "\200\0\0x\203\326(\5\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 12=
4) =3D=20
124

This kind of writes can take between seconds and minutes, while it usuall=
y=20
happens much faster than I can count. After the write() to the network=20
socket, other operations happen rather fast, until the next write to a=20
network socket. (I identified the troublesome filedescriptors by looking=20
to /proc/procid/fd).
After restarting the unfs3 daemon everything goes smooth for some time=20
(approximately 20min to 2h), until the next write to a filedescriptor sta=
lls.

Any idea whats going on? Until today this never happend before, neither w=
ith=20
2.6.x nor 2.4.x. As I wrote, on Friday we replaced 2.6.11.12 by 2.6.13, t=
he=20
configuration should be similar, only changes should be HZ set to 250 and=
=20
additionally the skge driver.=20
We already switched back from skge to sk98lin, but the problem seems to=20
remain.=20


Thanks,=09
	Bernd



--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
