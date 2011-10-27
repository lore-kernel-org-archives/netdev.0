From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v2 1/4] SUNRPC: rpcbind clients internals virtualization
Date: Thu, 27 Oct 2011 14:04:37 +0400
Message-ID: <4EA92CB5.8040805@parallels.com>
References: <20111025135637.5286.89632.stgit@localhost6.localdomain6> <20111025135749.5286.57091.stgit@localhost6.localdomain6> <4EA8FD98.9040500@netapp.com>
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
To: Bryan Schumaker <bjschuma@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EA8FD98.9040500@netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27.10.2011 10:43, Bryan Schumaker =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 10/25/2011 10:57 AM, Stanislav Kinsbursky wrote:
>> This patch moves static rpcbind internals to sunrpc part of network =
namespace
>
> Rather than saying that this patch moves the static internals, could =
you say that it creates the new network namespace internals?  The next =
patch switches things over, so it's not really correct to say that this=
 one moves everything.
>
> Alternatively, could this patch be merged with the next one so that y=
ou create and switch over to the new internals all at once?
>
> - Bryan
>

Yep, you right, Thanks.
Will resend it.

>> context. This will allow to create rcpbind clients per network names=
pace.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   net/sunrpc/netns.h |    5 +++++
>>   1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
>> index d013bf2..83eede3 100644
>> --- a/net/sunrpc/netns.h
>> +++ b/net/sunrpc/netns.h
>> @@ -9,6 +9,11 @@ struct cache_detail;
>>   struct sunrpc_net {
>>   	struct proc_dir_entry *proc_net_rpc;
>>   	struct cache_detail *ip_map_cache;
>> +
>> +	struct rpc_clnt *rpcb_local_clnt;
>> +	struct rpc_clnt *rpcb_local_clnt4;
>> +	spinlock_t rpcb_clnt_lock;
>> +	unsigned int rpcb_users;
>>   };
>>
>>   extern int sunrpc_net_id;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Best regards,
Stanislav Kinsbursky
