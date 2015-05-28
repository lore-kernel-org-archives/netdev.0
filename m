From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Possible issue in iproute2 package
Date: Thu, 28 May 2015 23:43:18 +0200
Message-ID: <55678BF6.3010402@iogearbox.net>
References: <1432847547.19276.47.camel@jrguzman-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@osdl.org" <shemminger@osdl.org>, vadim4j@gmail.com
To: "Guzman Mosqueda, Jose R" <jose.r.guzman.mosqueda@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35220 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667AbbE1VnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 17:43:21 -0400
In-Reply-To: <1432847547.19276.47.camel@jrguzman-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jose,

thanks for your report!

On 05/28/2015 11:12 PM, Guzman Mosqueda, Jose R wrote:
=2E..
> We're using iproute2 in a GNU-Linux project and I'm analyzing the cod=
e
> to try to find possible issues/gaps/risks.
> Since I'm not too familiar with the package yet I have a question abo=
ut
> a particular piece of code that could result in a memory corruption:
>
> Version: 4.0.0
> File: misc/ss.c
> Function: static void tcp_show_info(...)
> Line: ~1903
> Description: There is a memory allocation for a "s.cong_alg" variable=
:
> s.cong_alg =3D malloc(strlen(cong_attr + 1));
> The length is calculated about next position of the starting characte=
r.
> But next line there is a copy of the whole content:
> strcpy(s.cong_alg, cong_attr);
> I think there is a mistake and it should be something like:
> s.cong_alg =3D malloc(strlen(cong_attr) + 1);
> Is this the case? Is it a real bug?
> Also I don't see any checking for the value returned by the malloc ca=
ll,
> what if it returns a NULL pointer?

Cc'ing Vadim for ...

commit 8250bc9ff4e55a3ef397ed8c7612f1392d164295
Author: Vadim Kochan <vadim4j@gmail.com>
Date:   Tue Jan 20 16:14:24 2015 +0200

     ss: Unify inet sockets output

     Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

> Also I found something similar about line 1903:
> s.cong_alg =3D malloc(strlen(cong_attr + 1));
> strcpy(s.cong_alg, cong_attr);
>
> And another possible issue that I found:
>
> File: tc/tc_util.c
> Function: void print_rate(char *buf, int len, __u64 rate)
> Line: ~264
>
> In the case that user inputs a high value for rate, the "for" loop wi=
ll
> exit in the condition meaning that variable "i" get the value of 5 wh=
ich
> will be an invalid index for the "units" array due to that array has
> only 5 elements.
>
> I hope you can help me by checking these issues and tell me whether t=
hey
> are real issues or not since you know much better the code.
> Also I don't know if you have already this reported, I didn't find a
> list of issues for this package. Can you tell me where is such list?
>
> I really appreciate any help on this.
>
> Thanks in advance.
> Jose G.
>
>
>
>
>
>
>
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5
>
