From: Yair Gottdenker <yairgott@gmail.com>
Subject: Re: Increasing TCP initial cwnd
Date: Mon, 26 Oct 2009 17:07:45 +0200
Message-ID: <fa3cddca0910260807q714a24fdp1ffae601bb6f67ba@mail.gmail.com>
References: <fa3cddca0910260640s22d0396ey5fc51c51047bc2c@mail.gmail.com>
	 <alpine.DEB.2.00.0910261553180.19761@wel-95.cs.helsinki.fi>
	 <fa3cddca0910260728n61d8de61p9e58260c893d9f9f@mail.gmail.com>
	 <alpine.DEB.2.00.0910261629040.19761@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50548 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbZJZPPn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 11:15:43 -0400
Received: by bwz19 with SMTP id 19so2193068bwz.28
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 08:15:47 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.0910261629040.19761@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks,

I already had a look in it. Their changes that are related to changing
the initial cwnd  (snd_cwnd) are in several places in the patch:
1. tcp_ipv4.c in function tcp_init_cwnd. since currently I am working
with no metric this is irrelevant.
2. tcp_ipv4.c: in function tcp_v4_init_sock, which I applied
3. tcp_minisocks.c - which I applied
=2E They patched kernel 2.6.18.8 which is very old and there were a lot
of changes since that in the kernel tcp layer. I didn't test their
patch but applying the same logic to 2.6.31.3 doesn't seems to change
initial window size.

It is clear that in order to correctly make the change to the initial
cwnd, one should apply changes to many more scenarios like setting the
initial cwnd after idle time and more. I want to proceed step by step,
first the naive changes to make it work.




On Mon, Oct 26, 2009 at 4:38 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 26 Oct 2009, Yair Gottdenker wrote:
>
>> Thanks for the response.
>> I disabled metric by: net.ipv4.tcp_no_metrics_save =3D 1 in sysctl.c=
onf.
>> But just after the call to tcp_init_metrics in tcp_input.c there is
>> also a call to: tcp_init_congestion_control which calls the congesti=
on
>> control algorithm that is in used. I created my own and in the init
>> function I set the snd_cwnd to 10 and still there is no change and
>> only 4 segments are initially sent.
>> You are right tcp_slow_start has nothing to do with the cwnd size, I
>> mistakenly thought that the initial flow enters that function.
>
> Hopefully you don't mess up anything in there.
>
> Please see from http://www.cs.helsinki.fi/research/iwtcp/kernel-patch=
/
> I haven't had time/interest to bring it up to date but at least there=
's
> very clearly shown how the initial window can be configured through a
> sysctl (though don't try to patch it to late kernels, it would just b=
e
> a never ending pain for you :-)).
>
>> What do you mean RW? do you mean tcp read/write buffer size?
>
> RW =3D Restart Window (RFC2681 IIRC, nowadays also in RFC 5681 I thin=
k).
> ...It is related to slow-start after idle.
>
> --
> =A0i.
>
