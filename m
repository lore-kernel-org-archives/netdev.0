From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [Fix kernel crash in cipso_v4_sock_delattr ]
Date: Tue, 31 Mar 2015 10:52:43 -0700
Message-ID: <551ADEEB.1050206@schaufler-ca.com>
References: <1834203638.139231427778581653.JavaMail.weblogic@epmlwas08d>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Vaneet Narang <v.narang@samsung.com>,
	AJEET YADAV <ajeet.y@samsung.com>,
	Casey Schaufler <casey@schaufler-ca.com>
To: maninder1.s@samsung.com, Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.biz.mail.bf1.yahoo.com ([98.139.221.60]:26809 "EHLO
	smtp101.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752409AbbCaRwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:52:46 -0400
In-Reply-To: <1834203638.139231427778581653.JavaMail.weblogic@epmlwas08d>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/2015 10:09 PM, Maninder Singh wrote:
> We are currently using 3.10.58 kernel and  we are facing this issue f=
or samck enabled system.
> and as we can check in other APIs like netlbl_sock_getattr and netlbl=
_conn_setattr have this preventive check so we added this check for net=
lbl_sock_delattr also.
>
> And regarding patch re-submission, actually we have run checkpatch.pl=
 before submission(successfull)  But when we submit the patch our edito=
r changes tabs into space, we will resubmitt the patch ASAP.

=46urther review shows that the Smack code in 3.10.72 (I don't believe =
it changed
after 3.10.58) already checks for the address family being AF_INET. Thi=
s would indicate
that the netlink code is sending garbage to security_socket_sendmsg().

Can you provide a more specific test case? I would like to see if this =
problem is
present in newer kernels.

>
> Maninder Singh
> ------- Original Message -------
> Sender : Casey Schaufler<casey@schaufler-ca.com>
> Date : Mar 31, 2015 02:25 (GMT+09:00)
> Title : Re: [Fix kernel crash in cipso_v4_sock_delattr ]
>
> On 3/30/2015 4:32 AM, Paul Moore wrote:
>> On Monday, March 30, 2015 11:09:00 AM Maninder Singh wrote:
>>> Dear All,
>>> we found One Kernel Crash issue in cipso_v4_sock_delattr :-
>>> As Cipso supports only inet sockets so cipso_v4_sock_delattr will c=
rash when
>>> try to access any other socket type.  cipso_v4_sock_delattr access
>>> sk_inet->inet_opt which may contain not NULL but invalid address. w=
e found
>>> this issue with netlink socket.(reproducible by trinity using sendt=
o system
>>> call .)=20
>> Hello,
>>
>> First, please go read the Documentation/SubmittingPatches from the k=
ernel=20
>> sources; your patch needs to be resubmitted and the instructions in =
that file=20
>> will show you how to do it correctly next time.
>>
>> Second, this appears to only affect Smack based systems, yes?  SELin=
ux based=20
>> systems should have the proper checking in place to prevent this (th=
e checks=20
>> are handled in the LSM).
> This looks like a problem that was fixed some time ago.
> The current Smack code clearly checks for this. What kernel
> version are you testing against?
>
>> That said, it probably wouldn't hurt to add the=20
>> extra checking to netlbl_sock_delattr().  If you properly resubmit y=
our patch=20
>> I'll ACK it.
>>
>> -Paul
>> N=8B=A7=B2=E6=ECr=B8=9By=FA=E8=9A=D8b=B2X=AC=B6=C7=A7v=D8^=96)=DE=BA=
{.n=C7+=89=B7=A5=8A{=B1=91=EA=E7zX=A7=B6=17=9B=A1=DC=A8}=A9=9E=B2=C6 z=DA=
&j:+v=89=A8=BE=07=AB=91=EA=E7zZ+=80=CA+zf=A3=A2=B7h=9A=88=A7~=86=AD=86=DB=
i=FF=FB=E0z=B9=1E=AEw=A5=A2=B8?=99=A8=E8=AD=DA&=A2)=DF=A2=1Bf=94=F9^j=C7=
=ABy=A7m=85=E1@A=ABa=B6=DA=7F=FF=0C0=B6=ECh=AE=0F=E5=92i=7F
