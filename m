From: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] NFS: make nfs_client_lock per net ns
Date: Tue, 07 Feb 2012 09:35:00 -0500
Message-ID: <4F313694.8000008@netapp.com>
References: <20120123172631.29637.17188.stgit@localhost6.localdomain6>  <1328622659.4124.3.camel@lade.trondhjem.org>  <4F31308B.1090002@parallels.com> <1328623906.4124.10.camel@lade.trondhjem.org> <4F313595.7090004@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F313595.7090004-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/07/12 09:30, Bryan Schumaker wrote:

> On 02/07/12 09:11, Myklebust, Trond wrote:
>=20
>> On Tue, 2012-02-07 at 18:09 +0400, Stanislav Kinsbursky wrote:
>>> 07.02.2012 17:51, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> 8<----------------------------------------------------------------=
---------
>>>>  From 5a489156da4fd15dd143f2b21dd9657b97dcef88 Mon Sep 17 00:00:00=
 2001
>>>> From: Trond Myklebust<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
>>>> Date: Tue, 7 Feb 2012 00:05:11 -0500
>>>> Subject: [PATCH] NFS: Initialise the nfs_net->nfs_client_lock
>>>>
>>>> Ensure that we initialise the nfs_net->nfs_client_lock spinlock.
>>>> Also ensure that nfs_server_remove_lists() doesn't try to
>>>> dereference server->nfs_client before that is initialised.
>>>>
>>>
>>> Sorry.
>>> Patch looks nice. Except one notice below.
>>>
>>>> Signed-off-by: Trond Myklebust<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
>>>> Cc: Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>>>> ---
>>>>   fs/nfs/client.c |    6 +++++-
>>>>   1 files changed, 5 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>>> index 1a5cd49..f0dacad 100644
>>>> --- a/fs/nfs/client.c
>>>> +++ b/fs/nfs/client.c
>>>> @@ -1055,8 +1055,11 @@ static void nfs_server_insert_lists(struct =
nfs_server *server)
>>>>   static void nfs_server_remove_lists(struct nfs_server *server)
>>>>   {
>>>>   	struct nfs_client *clp =3D server->nfs_client;
>>>> -	struct nfs_net *nn =3D net_generic(clp->net, nfs_net_id);
>>>> +	struct nfs_net *nn;
>>>>
>>>> +	if (clp =3D=3D NULL)
>>>> +		return;
>>>> +	nn =3D net_generic(clp->net, nfs_net_id);
>>>>   	spin_lock(&nn->nfs_client_lock);
>>>>   	list_del_rcu(&server->client_link);
>>>>   	if (clp&&  list_empty(&clp->cl_superblocks))
>>>
>>> This check for clp !=3D NULL can be removed.
>>>
>>
>> Yep... I'll add that in...
>=20
>=20
>=20
> When I compile Trond's devel branch I get this:
>=20
> make[1]: Nothing to be done for `all'.
>   CHK     include/linux/version.h
>   CHK     include/generated/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/generated/compile.h
>   CHK     kernel/config_data.h
>   CC [M]  fs/nfs/idmap.o
> fs/nfs/idmap.c: In function 'rpc_pipefs_event':
> fs/nfs/idmap.c:535:9: error: implicit declaration of function 'net_ge=
neric' [-Werror=3Dimplicit-function-declaration]
> fs/nfs/idmap.c:535:50: error: 'nfs_net_id' undeclared (first use in t=
his function)
> fs/nfs/idmap.c:535:50: note: each undeclared identifier is reported o=
nly once for each function it appears in
> fs/nfs/idmap.c:540:82: error: dereferencing pointer to incomplete typ=
e
> fs/nfs/idmap.c:540:224: error: dereferencing pointer to incomplete ty=
pe
> cc1: some warnings being treated as errors
>=20
> make[2]: *** [fs/nfs/idmap.o] Error 1
> make[1]: *** [fs/nfs] Error 2
> make: *** [fs] Error 2
>=20
> I bisected it to this patch, probably a missing #include?


Ignore that, I was in the middle of bisecting something else and got co=
nfused.  This was still something I kept seeing during the bisect, thou=
gh.  I'll figure out which patch causes it in a few minutes...

>=20
> - Bryan
>=20
>>
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
