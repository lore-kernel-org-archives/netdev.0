From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: Resource leak in unshare
Date: Tue, 3 Nov 2015 09:48:22 +0100
Message-ID: <CACT4Y+arcDq=-kDn=y6oRFRSMApKKA7GrfAg_svTtLOVnnaVDA@mail.gmail.com>
References: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
 <87oafcrzsa.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87oafcrzsa.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 8:01 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Dmitry Vyukov <dvyukov@google.com> writes:
>
>> Hello,
>>
>> I am hitting the following warnings on
>> bcee19f424a0d8c26ecf2607b73c690802658b29 (4.3):
>
> Do you have any trace of the earlier failures?
>
> This appears to be something caused by an earlier failure (possibly
> whatever fails to allocate memory).  Having network devices present
> but being in the generic cleanup routines is wrong.
>
> If there is no additional information can you please rerun with the
> following change applied?  That should at least report which function is
> failing, and give us a good clue where to start debugging this.


So is it all fixed now? Or it is still clear how it can happen?
Eric (Dumazet), do you see how the WARNING can fire?
I don't have any logs at the moment, but I can run fuzzer for longer
to reproduce it again if necessary.



> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 2c2eb1b629b1..125c94af22b8 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -292,6 +292,7 @@ out:
>         return error;
>
>  out_undo:
> +       WARN(1, "net ops->init %pF returned with %d\n", ops->init, error);
>         /* Walk through the list backwards calling the exit functions
>          * for the pernet modules whose init functions did not fail.
>          */
