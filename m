From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH resend] tracing/events: convert NAPI's tracepoint via
	TRACE_EVENT
Date: Tue, 1 Sep 2009 07:04:36 -0400
Message-ID: <20090901110436.GA10918@hmsreliant.think-freely.org>
References: <4A9B6AA7.5020508@cn.fujitsu.com> <alpine.DEB.2.00.0908311402150.13931@gandalf.stny.rr.com> <4A9C73A4.20003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33454 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbZIALEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 07:04:50 -0400
Content-Disposition: inline
In-Reply-To: <4A9C73A4.20003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 09:06:44AM +0800, Xiao Guangrong wrote:
>=20
>=20
> Steven Rostedt wrote:
> > On Mon, 31 Aug 2009, Xiao Guangrong wrote:
> >=20
> >> - Convert NAPI's tracepoint via TRACE_EVENT macro, the output info=
rmation
> >>   like below:
> >>
> >>    sshd-2503  [000]    71.920846: napi_poll: ifname=3Deth0 state=3D=
0 weigth=3D16 poll=3Dpcnet32_poll
> >>    sshd-2503  [000]    72.020291: napi_poll: ifname=3Deth0 state=3D=
0 weigth=3D16 poll=3Dpcnet32_poll
> >>    sshd-2503  [000]    72.020418: napi_poll: ifname=3Deth0 state=3D=
NAPI_STATE_SCHED weigth=3D16 poll=3Dpcnet32_poll
> >>
> >> - Remove the "DECLARE_TRACE" definiens in include/trace/define_tra=
ce.h,
> >>   because TRACE_EVENT not use it
> >=20
> > The above really needs to be in a separate patch, since it is a tra=
cing=20
> > infrastructure change.
> >=20
>=20
> Hi Steven,
>=20
> We can't break this patch into two patches, because it's has redefine=
d 'DECLARE_TRACE'
> in include/trace/define_trace.h, like below:
>=20
> 1: if we remove 'DECLARE_TRACE' first, then NAPI's tracepoint can't d=
efine tracepoint
>    (it's a NAPI tracepoint's bug,
>     see my previous patch: http://marc.info/?l=3Dlinux-kernel&m=3D125=
118032931716&w=3D2)
>=20
> 2: if we convert NAPI's tracepoint first, it can't include more TRACE=
_EVENT .h files in
>    one .c file, the compiler will complain with variables redefined:
>=20
> include/trace/events/napi.h:15: error: redefinition of =E2=80=98__tps=
trtab_napi_poll=E2=80=99
> include/trace/events/napi.h:15: error: previous definition of =E2=80=98=
__tpstrtab_napi_poll=E2=80=99 was here
> include/trace/events/napi.h:15: error: redefinition of =E2=80=98__tra=
cepoint_napi_poll=E2=80=99
> include/trace/events/napi.h:15: error: previous definition of =E2=80=98=
__tracepoint_napi_poll=E2=80=99 was here
> In file included from include/trace/ftrace.h:644,
>=20
> So, I think we do better fix this bug early, then other people can go=
 on his work on ftrace.
>=20
> Hi Neil,
>=20
> How do you think about this patch, can you give me some comments?
>=20
=46or the things that I use the napi_poll traepoint for, this is all  f=
ine by me,
so ack as far as that goes, but I'm probably not qualified to comment o=
n the
tracepoint infrastructure changes you've made (the recent skb ftracer a=
rgument
is like a good indicator of that :) )

Neil

>=20
> Thanks,
> Xiao
>=20
>=20
