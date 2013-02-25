From: Syam Sidhardhan <syamsidhardh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Fix possible NULL pointer dereference
Date: Mon, 25 Feb 2013 20:51:09 +0530
Message-ID: <CAFBvHifgLh7W58mw64Ycnn7qT6_3isYGpJAkRXuOV7KZFdSniQ@mail.gmail.com>
References: <1361744605-28235-1-git-send-email-s.syam@samsung.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9235DE4C7@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DE4C7-VGJ86jkg8PeBTCzCEi1xmXOR4cbS7gtM96Bgd4bDwmQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Trond,

On Mon, Feb 25, 2013 at 4:05 AM, Myklebust, Trond
<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, 2013-02-25 at 03:53 +0530, Syam Sidhardhan wrote:
>> Check for cred == NULL has to be done before accessing cred.
>>
>> Signed-off-by: Syam Sidhardhan <s.syam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
>> ---
>>  net/sunrpc/auth.c |    7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index f529404..18678a6 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -695,10 +695,13 @@ rpcauth_invalcred(struct rpc_task *task)
>>  {
>>       struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>>
>> +     if (cred == NULL)
>> +             return;
>> +
>>       dprintk("RPC: %5u invalidating %s cred %p\n",
>>               task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>> -     if (cred)
>> -             clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>> +
>> +     clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>>  }
>>
>>  int
>
> Do we need that check at all?

I'm not sure whether we need that check or not. However
similar functions such as rpcauth_refreshcred(), rpcauth_uptodatecred() etc
are doing the same check inside. Cppcheck is throwing an error too.

Regards,
Syam
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
