From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [Devel] [PATCH] SUNRPC: search for service transports in network
 namespace context
Date: Tue, 20 Dec 2011 14:31:07 +0400
Message-ID: <4EF063EB.6030104@parallels.com>
References: <20111220101419.5673.21926.stgit@localhost6.localdomain6> <4EF062B1.3030401@parallels.com>
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
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EF062B1.3030401@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

20.12.2011 14:25, Glauber Costa =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 12/20/2011 03:14 PM, Stanislav Kinsbursky wrote:
>> Service transports are parametrized by network namespace. And thus l=
ookup of
>> transport instance have to take network namespace into account.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>    fs/lockd/svc.c                  |    2 +-
>>    fs/nfsd/nfsctl.c                |    4 ++--
>>    include/linux/sunrpc/svc_xprt.h |    3 ++-
>>    net/sunrpc/svc_xprt.c           |    6 +++++-
>>    4 files changed, 10 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>> index c061b9a..ff379ff 100644
>> --- a/fs/lockd/svc.c
>> +++ b/fs/lockd/svc.c
>> @@ -193,7 +193,7 @@ static int create_lockd_listener(struct svc_serv=
 *serv, const char *name,
>>    {
>>    	struct svc_xprt *xprt;
>>
>> -	xprt =3D svc_find_xprt(serv, name, family, 0);
>> +	xprt =3D svc_find_xprt(serv, name,&init_net, family, 0);
>>    	if (xprt =3D=3D NULL)
>>    		return svc_create_xprt(serv, name,&init_net, family, port,
>>    						SVC_SOCK_DEFAULTS);
>
> I might be missing something, but isn't it (at least part of it) alre=
ady
> merged in commit fc5d00b04a3a58cac8620403dfe9f43f72578ec1 ?
>

Nope, those one was parameterizing transport creation by network namesp=
ace.
This one is parameterizing search in poll of existent service transport=
s by=20
network namespace.

--=20
Best regards,
Stanislav Kinsbursky
