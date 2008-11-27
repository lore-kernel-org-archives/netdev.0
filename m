From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH 6/6] fs: Introduce kern_mount_special() to mount	special
 vfs
Date: Thu, 27 Nov 2008 11:04:38 +0100
Message-ID: <492E70B6.70108@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDCAB.1070204@cosmosbay.com> <20081127095321.GE13860@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081127095321.GE13860-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig a =E9crit :
> On Thu, Nov 27, 2008 at 12:32:59AM +0100, Eric Dumazet wrote:
>> This function arms a flag (MNT_SPECIAL) on the vfs, to avoid
>> refcounting on permanent system vfs.
>> Use this function for sockets, pipes, anonymous fds.
>=20
> special is not a useful name for a flag, by definition everything tha=
t
> needs a flag is special compared to the version that doesn't need a
> flag.
>=20
> The general idea of skippign the writer counts makes sense, but pleas=
e
> give it a descriptive name that explains the not unmountable thing.
> And please kill your kern_mount wrapper and just set the flag manuall=
y.
>=20
> Also I think it should be a superblock flag, not a mount flag as you
> don't want thse to differ for multiple mounts of the same filesystem.
>=20
>=20

Hum.. we have a superblock flag already, but testing it in mntput()/mnt=
get()
is going to be a litle bit expensive if we add a derefence ?

if (mnt && mnt->mnt_sb->s_flags & MS_SPECIAL) {
   ...
}
