From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: skge: reboot on sysfs resource0 access
Date: Fri, 9 Sep 2005 19:34:50 +0200
Message-ID: <200509091934.51301.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

today we tried 2.6.13 on our server and also tried to use the skge driver=
.=20
Well, in principle it works fine, until I became curious about the sysfs=20
values. Stupid me, I was using the midnight commander to read the values.=
=20
When I opened "/sys/bus/pci/drivers/skge/0000:01:01.0/resource0", the sys=
tem=20
immediately rebooted. After the reboot we tested using cat to the resourc=
e0=20
file, which gave an input/output error. Using again the mc, the system ag=
ain=20
immediately rebooted.
Well, I guess I better don't use the midnight commander in the future, bu=
t=20
somehow I think it shouldn't cause the system to reboot, should it? Is th=
e=20
i/o error of cat supposed to happen?

Maybe it helps, here is a strace of mc's open for a normal file:

open("/home/bernd/notes", O_RDONLY|O_NONBLOCK|O_LARGEFILE) =3D 6
fstat64(6, {st_mode=3DS_IFREG|0644, st_size=3D96, ...}) =3D 0
fcntl64(102, F_GETFL)                   =3D -1 EBADF (Bad file descriptor=
)
read(6, "http", 4)                      =3D 4
mmap2(NULL, 96, PROT_READ, MAP_SHARED, 6, 0) =3D 0x402fe000
select(5, [4], NULL, NULL, {0, 0})      =3D 0 (Timeout)
select(5, [4], NULL, NULL, {0, 0})      =3D 0 (Timeout)
write(1, "\33[1;1H\33[m\17\33[30m\33[46mFile: notes "..., 4019) =3D 4019


Thanks,
	Bernd


--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
