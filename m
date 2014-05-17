From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
Date: Sat, 17 May 2014 13:17:28 -0400
Message-ID: <CAHQdGtRd-uKvRU8DD9zK-MEF0B10=rESrQAPJoQ8hTunwG883A@mail.gmail.com>
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<5376025B.6010202@cogentembedded.com>
	<CAFo99gatLzLpOu92N23bMQ=a25BTnK3QK2rAzoQJcU3oxMuMgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFo99gatLzLpOu92N23bMQ=a25BTnK3QK2rAzoQJcU3oxMuMgA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 17, 2014 at 12:36 PM, Rickard Strandqvist
<rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org> wrote:
> Hi
>
> I have made a new patch according Sergei specification.
>

I'll be happy to apply this patch once someone explains to me why we
can't just remove that check for cred !=3D NULL, however I'm not
applying a patch purely in order to silence a warning from cppcheck.

Cheers,
   Trond

> But there remains Tronds question though.
>
> Best regards
> Rickard Strandqvist
>
>
> 2014-05-16 14:19 GMT+02:00 Sergei Shtylyov <sergei.shtylyov@cogentemb=
edded.com>:
>> Hello.
>>
>>
>> On 16-05-2014 1:56, Rickard Strandqvist wrote:
>>
>>> There is otherwise a risk of a possible null pointer dereference.
>>
>>
>>> Was largely found by using a static code analysis program called cp=
pcheck.
>>
>>
>>> Signed-off-by: Rickard Strandqvist
>>> <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
>>> ---
>>>   net/sunrpc/auth.c |   10 +++++++---
>>>   1 fil =C3=A4ndrad, 7 till=C3=A4gg(+), 3 borttagningar(-)
>>
>>
>>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>>> index 5285ead..3a55698 100644
>>> --- a/net/sunrpc/auth.c
>>> +++ b/net/sunrpc/auth.c
>>> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>>>   {
>>>         struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>>>
>>> -       dprintk("RPC: %5u invalidating %s cred %p\n",
>>> -               task->tk_pid, cred->cr_auth->au_ops->au_name, cred)=
;
>>> -       if (cred)
>>> +       if (cred) {
>>> +               dprintk("RPC: %5u invalidating %s cred %p\n",
>>> +                       task->tk_pid, cred->cr_auth->au_ops->au_nam=
e,
>>> cred);
>>> +
>>>                 clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>>> +       }
>>> +       else
>>
>>
>>    } and *else* should be on the same line, and there should be {} i=
n the
>> *else* arm since there's {} in the *if* arm already, according to
>> Documentation/CodingStyle.
>>
>>
>>> +               dprintk("RPC: %5u invalidating is NULL\n", task->tk=
_pid);
>>
>>
>>    That's not a proper English, I'm afraid.
>>
>>>   }
>>
>>
>> WBR, Sergei
>>
>>



--=20
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
