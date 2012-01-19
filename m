From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 2/5] SUNRPC: create unix gid cache per network namespace
Date: Thu, 19 Jan 2012 21:00:23 +0400
Message-ID: <4F184C27.8080101@parallels.com>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <20120119144914.9957.73951.stgit@localhost6.localdomain6> <20120119162431.GC527@fieldses.org>
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
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120119162431.GC527@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.01.2012 20:24, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, Jan 19, 2012 at 06:49:14PM +0400, Stanislav Kinsbursky wrote:
>> This patch makes unix_gid_cache cache detail allocated and registere=
d per
>> network namespace context.
>> Thus with this patch unix_gid_cache contents for network namespace "=
X" are
>> controlled from proc file system mount for the same network namespac=
e "X".
>
> I'm confused--this seems half-done.  I see that you're creating the g=
id
> caches dynamically, but there's still this static definition:
>

This static definition is used as a template now.
Have a look at the first path of the series: cache creation routine dup=
licates=20
incomming cache_detail and initializes net and hash_table fields in fre=
shly=20
created copy.
This copy is the new per-net cache_detail instance.

>>   struct cache_detail unix_gid_cache =3D {
>>   	.owner		=3D THIS_MODULE,
>>   	.hash_size	=3D GID_HASHMAX,
>> -	.hash_table	=3D gid_table,
>>   	.name		=3D "auth.unix.gid",
>>   	.cache_put	=3D unix_gid_put,
>>   	.cache_upcall	=3D unix_gid_upcall,
>
> And it looks like unix_gid_lookup is still using this static
> unix_gid_cache.  Maybe I'm missing something....
>

Yep, thanks for the catch.
My fault, I've missed this usage.


--=20
Best regards,
Stanislav Kinsbursky
