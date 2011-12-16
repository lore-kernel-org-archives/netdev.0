From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v9 1/9] Basic kernel memory functionality for the Memory Controller
Date: Thu, 15 Dec 2011 22:20:52 -0800
Message-ID: <CAHH2K0YUK9CVk4Ds3cPA=6SNjX0y79nSo+Vy8r1H5PiVXA1RWQ@mail.gmail.com>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com> <1323676029-5890-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org,
	avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323676029-5890-2-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 11, 2011 at 11:47 PM, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>=
 wrote:
> +Memory limits as specified by the standard Memory Controller may or =
may not
> +take kernel memory into consideration. This is achieved through the =
file
> +memory.independent_kmem_limit. A Value different than 0 will allow f=
or kernel

s/Value/value/

It is probably worth documenting the default value for
memory.independent_kmem_limit?  I figure it would be zero at root and
and inherited from parents.  But I think the implementation differs.

> @@ -277,6 +281,11 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0unsigned long =A0 move_charge_at_immigrate;
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* Should kernel memory limits be stabilished indepen=
dently
> + =A0 =A0 =A0 =A0* from user memory ?
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 kmem_independent_accounting=
;

I have no serious objection, but a full int seems like overkill for a
boolean value.

> +static int register_kmem_files(struct cgroup *cont, struct cgroup_su=
bsys *ss)
> +{
> + =A0 =A0 =A0 int ret =3D 0;
> +
> + =A0 =A0 =A0 ret =3D cgroup_add_files(cont, ss, kmem_cgroup_files,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ARRAY_SI=
ZE(kmem_cgroup_files));
> + =A0 =A0 =A0 return ret;

If you want to this function could be condensed down to:
  return cgroup_add_files(...);
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
