From: =?utf-8?B?SsO2cm4=?= Engel <joern-PCqxUs/MD9bYtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v2 4/5] fs: Introduce SINGLE dentries for pipes, socket, anon fd
Date: Sat, 29 Nov 2008 11:38:36 +0100
Message-ID: <20081129103836.GA11959@logfs.org>
References: <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <493100E7.3030907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <493100E7.3030907-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 29 November 2008 09:44:23 +0100, Eric Dumazet wrote:
>
> +struct dentry *d_alloc_single(const struct qstr *name, struct inode =
*inode)
> +{
> +	struct dentry *entry;
> +
> +	entry =3D d_alloc(NULL, name);
> +	if (entry) {
> +		entry->d_sb =3D inode->i_sb;
> +		entry->d_parent =3D entry;
> +		entry->d_flags |=3D DCACHE_SINGLE | DCACHE_DISCONNECTED;
> +		entry->d_inode =3D inode;
> +		fsnotify_d_instantiate(entry, inode);
> +		security_d_instantiate(entry, inode);
> +	}
> +	return entry;

Calling the struct dentry entry had me onfused a bit.  I believe
everyone else (including the code you removed) uses dentry.

> @@ -918,7 +906,7 @@ struct file *create_write_pipe(int flags)
>  	struct inode *inode;
>  	struct file *f;
>  	struct dentry *dentry;
> -	struct qstr name =3D { .name =3D "" };
> +	static const struct qstr name =3D { .name =3D "" };
> =20
>  	err =3D -ENFILE;
>  	inode =3D get_pipe_inode();
=2E..
> @@ -371,20 +358,13 @@ static int sock_alloc_fd(struct file **filep, i=
nt flags)
>  static int sock_attach_fd(struct socket *sock, struct file *file, in=
t flags)
>  {
>  	struct dentry *dentry;
> -	struct qstr name =3D { .name =3D "" };
> +	static const struct qstr name =3D { .name =3D "" };

These two could even be combined.

And of course I realize that I comment on absolute trivialities.  On th=
e
whole, I couldn't spot a real problem in your patches.

J=C3=B6rn

--=20
Public Domain  - Free as in Beer
General Public - Free as in Speech
BSD License    - Free as in Enterprise
Shared Source  - Free as in "Work will make you..."
