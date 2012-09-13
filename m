From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 4/8] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Thu, 13 Sep 2012 16:07:05 +0800
Message-ID: <50519429.3090809@huawei.com>
References: <1347522655-24158-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347522655-24158-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2012/9/13 15:50, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>=20
> CGROUP_BUILTIN_SUBSYS_COUNT is used as start index or stop index when
> looping over the subsys array looking either at the builtin or the
> module subsystems. Since all the builtin subsystems have an id which
> is lower then CGROUP_BUILTIN_SUBSYS_COUNT we know that any module wil=
l
> have an id larger than CGROUP_BUILTIN_SUBSYS_COUNT. In short the ids
> are sorted.
>=20
> We are about to change id assignment to happen only at compile time
> later in this series. That means we can't rely on the above trick
> since all ids will always be defined at compile time. Furthermore,
> ordering the builtin subsystems and the module subsystems is not
> really necessary.
>=20
> So we need a different way to know which subsystem is a builtin or a
> module one. We can use the subsys[]->module pointer for this. Any
> place where we need to know if a subsys is module we just check for
> the pointer. If it is NULL then the subsystem is a builtin one.
>=20
> With this we are able to drop the CGROUP_BUILTIN_SUBSYS_COUNT
> enum. Though we need to introduce a temporary placeholder so that we
> don't get a compilation error when only CONFIG_CGROUP is selected and
> no single controller. An empty enum definition is not valid. Later in
> this series we are able to remove the placeholder again.
>=20
> And with this change we get a fix for this:
>=20
> kernel/cgroup.c: In function =E2=80=98cgroup_load_subsys=E2=80=99:
> kernel/cgroup.c:4326:38: warning: array subscript is below array boun=
ds [-Warray-bounds]
>=20
> when CONFIG_CGROUP=3Dy and no built in controller was enabled.
>=20
> Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
> Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  include/linux/cgroup.h |  2 +-
>  kernel/cgroup.c        | 68 +++++++++++++++++++++++++++++-----------=
----------
>  2 files changed, 41 insertions(+), 29 deletions(-)
>=20

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
