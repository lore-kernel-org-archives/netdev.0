From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.23-mm1 s390 driver problem
Date: Fri, 19 Oct 2007 02:27:19 -0700
Message-ID: <20071019022719.537ee71f.akpm@linux-foundation.org>
References: <20071018200148.GA14234@vino.hallyn.com>
	<200710182215.56428.borntraeger@de.ibm.com>
	<20071018203151.GA15382@vino.hallyn.com>
	<1192780036.25150.7.camel@localhost> <471875E0.8040308@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Christian-YRGon0hq2jhQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <471875E0.8040308-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Oct 2007 11:16:16 +0200 Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrot=
e:

> Martin Schwidefsky wrote:
> > On Thu, 2007-10-18 at 15:31 -0500, Serge E. Hallyn wrote:
> >> Quoting Christian Borntraeger (borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
> >>> Am Donnerstag, 18. Oktober 2007 schrieb Serge E. Hallyn:
> >>>> Sigh, well this turned out less informative than I'd liked.
> >>>> After bisecting 2.6.23 to 2.6.23-mm1, I found that
> >>>> git-s390.patch is the one breaking my s390 boot :(
> >>>> (Frown bc it's a conglomeration of patches0
> >>>>
> >>>> Symptom is:
> >>>> 	"Cannot open root device "dasdd2" or unknown-block(94,14)"
> >>>> even though dasdd2 appeared to be found earlier in the boot.  I al=
so
> >>>> get
> >>> Can you post the full console output from IPL to the unsuccessful e=
nd?
> >> Yeah, sorry, appended below.
> >>
> >> I had thought that the line
> >> 	sysctl table check failed: /sunrpc/transports .7249.14 Missing stra=
tegy
> >> meant that the fix referenced in http://lkml.org/lkml/2007/10/11/48
> >> would fix it, but it appeared to have no effect.
> >=20
> > This is the vmlinux.lds.S problem. The cleanup patch from Sam Ravnbor=
g
> > moved the __initramfs_start and __initramfs_end symbols into
> > the .init.ramfs section. This is in itself not a problem, but it
> > surfaced a bug: there is no *(.init.initramfs), that needs to be
> > *(init.ramfs). I corrected this in the upstream patch but 2.6.23-mm1 =
has
> > the older one that still causes the "Cannot open root device". For
> > 2.6.23-mm1 use the patch below.
> >=20
>=20
> thanks martin,=20
>=20
> that helped going a little further in the boot process but we then have=
=20
> a network issue when bringing the network interface up :

please cc netdev on network issues.

> Bringing up interface eth0:  ------------=DD cut here =A8------------=20
> Kernel BUG at 0000000000000002 =DDverbose debug info unavailable=A8=20
> illegal operation: 0001 =DD#1=A8=20
> Modules linked in:=20
> CPU:    0    Not tainted=20
> Process ip (pid: 1167, task: 0000000001d46038, ksp: 00000000025efb28)=20
> Krnl PSW : 0704200180000000 0000000000000002 (0x2)=20
>            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 EA:3=20
> Krnl GPRS: 0000000000000000 0000000000000000 000000000241f600 000000000=
1c8d
>            00000000000086dd 0000000001eb6d70 0000000000000000 000000000=
1c8d
>            0000000001eb6d40 00000000003abc28 0000000001eb6d00 000000000=
25ef
>            000000000241f600 00000000003b6d18 00000000002b33d2 000000000=
25ef
> Krnl Code:>0000000000000002: 0000               unknown=20
>            0000000000000004: 0000               unknown=20
>            0000000000000006: 0000               unknown=20
>            0000000000000008: 0000               unknown=20
>            000000000000000a: 0000               unknown=20
>            000000000000000c: 0000               unknown=20
>            000000000000000e: 0000               unknown=20
>            0000000000000010: 0000               unknown=20
> Call Trace:=20
> (=DD<00000000002b3352>=A8 neigh_connected_output+0x76/0x138)=20
>  =DD<0000000000325402>=A8 ip6_output2+0x2da/0x470=20
>  =DD<0000000000326ea6>=A8 ip6_output+0x816/0x1064=20
>  =DD<0000000000338e46>=A8 __ndisc_send+0x416/0x6a8=20
>  =DD<0000000000339330>=A8 ndisc_send_rs+0x58/0x68=20
>  =DD<000000000032cbf4>=A8 addrconf_dad_completed+0xbc/0x100=20
>  =DD<000000000032d2de>=A8 addrconf_dad_start+0xa2/0x14c=20
>  =DD<000000000032d408>=A8 addrconf_add_linklocal+0x80/0xa8=20
>  =DD<000000000032fa7e>=A8 addrconf_notify+0x2de/0x8d4=20
>  =DD<0000000000383990>=A8 notifier_call_chain+0x5c/0x98=20
>  =DD<0000000000063bca>=A8 __raw_notifier_call_chain+0x26/0x34=20
>  =DD<0000000000063c06>=A8 raw_notifier_call_chain+0x2e/0x3c=20
>  =DD<00000000002aa54c>=A8 call_netdevice_notifiers+0x34/0x44=20
>  =DD<00000000002ad1aa>=A8 dev_open+0x9e/0xe0=20
>  =DD<00000000002ad80a>=A8 dev_change_flags+0x9e/0x1cc=20
>  =DD<0000000000302c74>=A8 devinet_ioctl+0x650/0x73c=20
>  =DD<00000000003050ba>=A8 inet_ioctl+0xde/0xf4=20
>  =DD<000000000029a8d0>=A8 sock_ioctl+0x1cc/0x2dc=20
>  =DD<00000000000cb844>=A8 do_ioctl+0xb8/0xcc=20
>  =DD<00000000000cb8f2>=A8 vfs_ioctl+0x9a/0x3ec=20
>  =DD<00000000000cbc96>=A8 sys_ioctl+0x52/0x7c=20
>  =DD<0000000000022484>=A8 sysc_noemu+0x10/0x16=20
>  =DD<000002000010df12>=A8 0x2000010df12=20

that's a network issue ;)

> 00000000002b3352 gives : include/linux/netdevice.h:819
>=20

I have a feeling that we fixed this.  But there's no BUG at 2.6.23-mm1's
include/linux/netdevice.h:819.  How about setting
CONFIG_DEBUG_BUGVERBOSE=3Dy?
