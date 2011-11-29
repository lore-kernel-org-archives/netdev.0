From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
Date: Tue, 29 Nov 2011 16:19:26 +0400
Message-ID: <4ED4CDCE.9080804@parallels.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6> <20111129091037.20730.59391.stgit@localhost6.localdomain6> <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "tao.peng@emc.com" <tao.peng@emc.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

29.11.2011 16:00, tao.peng@emc.com =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.k=
ernel.org] On Behalf Of Stanislav
>> Kinsbursky
>> Sent: Tuesday, November 29, 2011 6:11 PM
>> To: Trond.Myklebust@netapp.com
>> Cc: linux-nfs@vger.kernel.org; xemul@parallels.com; neilb@suse.de; n=
etdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org; jbottomley@parallels.com; bfields@fieldses.o=
rg; davem@davemloft.net;
>> devel@openvz.org
>> Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference fr=
om blocklayout routines
>>
>> This is a cleanup patch. We don't need this reference anymore, becau=
se
>> blocklayout pipes dentries now creates and destroys in per-net opera=
tions and
>> on PipeFS mount/umount notification.
>> Note that nfs4blocklayout_register_net() now returns 0 instead of -E=
NOENT in
>> case of PipeFS superblock absence. This is ok, because blocklayout p=
ipe dentry
>> will be created on PipeFS mount event.
> When is the "pipefs mount event" going to happen? When inserting kern=
el modules or when user issues mount command?
>

When user issues mount command.
Kernel mounts of PipeFS has been removed with all these patch sets I've=
 sent=20
already.


> Thanks,
> Tao
>
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   fs/nfs/blocklayout/blocklayout.c |    9 +--------
>>   1 files changed, 1 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/b=
locklayout.c
>> index acf7ac9..8211ffd 100644
>> --- a/fs/nfs/blocklayout/blocklayout.c
>> +++ b/fs/nfs/blocklayout/blocklayout.c
>> @@ -1032,7 +1032,7 @@ static struct dentry *nfs4blocklayout_register=
_net(struct net *net,
>>
>>   	pipefs_sb =3D rpc_get_sb_net(net);
>>   	if (!pipefs_sb)
>> -		return ERR_PTR(-ENOENT);
>> +		return 0;
>>   	dentry =3D nfs4blocklayout_register_sb(pipefs_sb, pipe);
>>   	rpc_put_sb_net(net);
>>   	return dentry;
>> @@ -1083,7 +1083,6 @@ static struct pernet_operations nfs4blocklayou=
t_net_ops =3D {
>>
>>   static int __init nfs4blocklayout_init(void)
>>   {
>> -	struct vfsmount *mnt;
>>   	int ret;
>>
>>   	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func_=
_);
>> @@ -1093,12 +1092,6 @@ static int __init nfs4blocklayout_init(void)
>>   		goto out;
>>
>>   	init_waitqueue_head(&bl_wq);
>> -
>> -	mnt =3D rpc_get_mount();
>> -	if (IS_ERR(mnt)) {
>> -		ret =3D PTR_ERR(mnt);
>> -		goto out_remove;
>> -	}
>>   	ret =3D rpc_pipefs_notifier_register(&nfs4blocklayout_block);
>>   	if (ret)
>>   		goto out_remove;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--=20
Best regards,
Stanislav Kinsbursky
