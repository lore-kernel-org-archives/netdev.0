From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: Re: [PATCH resend] tracing/events: convert NAPI's tracepoint via
 TRACE_EVENT
Date: Tue, 01 Sep 2009 09:06:44 +0800
Message-ID: <4A9C73A4.20003@cn.fujitsu.com>
References: <4A9B6AA7.5020508@cn.fujitsu.com> <alpine.DEB.2.00.0908311402150.13931@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752642AbZIABH2@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0908311402150.13931@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Steven Rostedt wrote:
> On Mon, 31 Aug 2009, Xiao Guangrong wrote:
>=20
>> - Convert NAPI's tracepoint via TRACE_EVENT macro, the output inform=
ation
>>   like below:
>>
>>    sshd-2503  [000]    71.920846: napi_poll: ifname=3Deth0 state=3D0=
 weigth=3D16 poll=3Dpcnet32_poll
>>    sshd-2503  [000]    72.020291: napi_poll: ifname=3Deth0 state=3D0=
 weigth=3D16 poll=3Dpcnet32_poll
>>    sshd-2503  [000]    72.020418: napi_poll: ifname=3Deth0 state=3DN=
API_STATE_SCHED weigth=3D16 poll=3Dpcnet32_poll
>>
>> - Remove the "DECLARE_TRACE" definiens in include/trace/define_trace=
=2Eh,
>>   because TRACE_EVENT not use it
>=20
> The above really needs to be in a separate patch, since it is a traci=
ng=20
> infrastructure change.
>=20

Hi Steven,

We can't break this patch into two patches, because it's has redefined =
'DECLARE_TRACE'
in include/trace/define_trace.h, like below:

1: if we remove 'DECLARE_TRACE' first, then NAPI's tracepoint can't def=
ine tracepoint
   (it's a NAPI tracepoint's bug,
    see my previous patch: http://marc.info/?l=3Dlinux-kernel&m=3D12511=
8032931716&w=3D2)

2: if we convert NAPI's tracepoint first, it can't include more TRACE_E=
VENT .h files in
   one .c file, the compiler will complain with variables redefined:

include/trace/events/napi.h:15: error: redefinition of =E2=80=98__tpstr=
tab_napi_poll=E2=80=99
include/trace/events/napi.h:15: error: previous definition of =E2=80=98=
__tpstrtab_napi_poll=E2=80=99 was here
include/trace/events/napi.h:15: error: redefinition of =E2=80=98__trace=
point_napi_poll=E2=80=99
include/trace/events/napi.h:15: error: previous definition of =E2=80=98=
__tracepoint_napi_poll=E2=80=99 was here
In file included from include/trace/ftrace.h:644,

So, I think we do better fix this bug early, then other people can go o=
n his work on ftrace.

Hi Neil,

How do you think about this patch, can you give me some comments?


Thanks,
Xiao
