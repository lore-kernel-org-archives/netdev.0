From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
Date: Fri, 16 May 2014 00:10:53 +0200
Message-ID: <CAFo99ga5hw+KLT+5gY5sArsykUnBY9fZSvZaSnK54S5HW-nZHw@mail.gmail.com>
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CAABAsM69JO2F95+uVzbSzOSbnNz2ae0kdffy8m-pGDRr_QR=+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@primarydata.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAABAsM69JO2F95+uVzbSzOSbnNz2ae0kdffy8m-pGDRr_QR=+g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I do not know, I'm not an expert on this code.
But since there before was a if (cred) someone must have thought this
could happen.

Best regards
Rickard Strandqvist


2014-05-16 0:07 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.=
com>:
> On Thu, May 15, 2014 at 5:56 PM, Rickard Strandqvist
> <rickard_strandqvist@spectrumdigital.se> wrote:
>> There is otherwise a risk of a possible null pointer dereference.
>>
>> Was largely found by using a static code analysis program called cpp=
check.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigi=
tal.se>
>> ---
>>  net/sunrpc/auth.c |   10 +++++++---
>>  1 fil =C3=A4ndrad, 7 till=C3=A4gg(+), 3 borttagningar(-)
>>
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index 5285ead..3a55698 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>>  {
>>         struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>>
>> -       dprintk("RPC: %5u invalidating %s cred %p\n",
>> -               task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>> -       if (cred)
>> +       if (cred) {
>> +               dprintk("RPC: %5u invalidating %s cred %p\n",
>> +                       task->tk_pid, cred->cr_auth->au_ops->au_name=
, cred);
>> +
>>                 clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>> +       }
>> +       else
>> +               dprintk("RPC: %5u invalidating is NULL\n", task->tk_=
pid);
>>  }
>>
>>
>
> Can you please explain how we can get to rpcauth_invalcred() without =
a
> valid cred pointer? I'm not seeing it...
>
> Cheers
>   Trond
