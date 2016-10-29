From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/dccp: warning in dccp_feat_clone_sp_val/__might_sleep
Date: Sat, 29 Oct 2016 19:59:53 +0200
Message-ID: <CAAeHK+x6+CU+1KJNOpnoyyZoqH7_dcrWFVGU1KrJYVwJSzdxPg@mail.gmail.com>
References: <CAAeHK+z-SAq-YhHarfc94dguyXCJ_tv8n=ZVdLTRsYEy0cK-pQ@mail.gmail.com>
 <CAM_iQpX_xw35MUyd9aON5U=HmUoRafeoOF+_vSTHGYnrXd-CHg@mail.gmail.com>
 <CAAeHK+y9ENvGzJEQtRy_5DEzCfhGEYXR5CPpgwXy_FoOtFUf3Q@mail.gmail.com> <1477762981.7065.272.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477762981.7065.272.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

Tested with both patches applied, still seeing the warning.

Thanks!

On Sat, Oct 29, 2016 at 7:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-10-29 at 19:06 +0200, Andrey Konovalov wrote:
>> Hi Cong,
>>
>> Tested with your patch, still getting a warning, though it's a little different:
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 1 PID: 3876 at kernel/sched/core.c:7724
>> __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
>> do not call blocking ops when !TASK_RUNNING; state=1 set at
>> [<ffffffff811f5a5c>] prepare_to_wait+0xbc/0x210
>> kernel/sched/wait.c:178
>> Modules linked in:
>
> This looks like the following patch is needed, can you test it ?
> Thanks !
>
> diff --git a/net/dccp/output.c b/net/dccp/output.c
> index b66c84db0766..74d8583a0d52 100644
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -228,6 +228,7 @@ static int dccp_wait_for_ccid(struct sock *sk, unsigned long delay)
>
>         remaining = schedule_timeout(delay);
>
> +       sched_annotate_sleep();
>         lock_sock(sk);
>         sk->sk_write_pending--;
>         finish_wait(sk_sleep(sk), &wait);
>
>
>
