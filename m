From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: [PATCH] Re: some tc commands fail on 2.6.29-rc6-git5, works on
	2.6.28.7
Date: Thu, 5 Mar 2009 00:32:08 +0000
Message-ID: <a5d9929e0903041632r56af217r3b6645d3d01c8ca5@mail.gmail.com>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com>
	 <20090301165729.8e08e1d7.akpm@linux-foundation.org>
	 <49AC28FF.1040102@gmail.com>
	 <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com>
	 <1236135028.7883.44.camel@Maple> <20090304233458.GA8303@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Dykstra <john.dykstra1@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:62512 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbZCEAcM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 19:32:12 -0500
In-Reply-To: <20090304233458.GA8303@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

Confirmed working now on latest 2.6.29-rc6 git.

Thank you very much all for the prompt answer and solution, really impr=
essive.

Back to work on the ultimate custom firewall *evil laugh*.

Cheers,
Joao Correia
Centro de Informatica
Universidade da Beira Interior
Portugal

On Wed, Mar 4, 2009 at 11:34 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On Tue, Mar 03, 2009 at 08:50:28PM -0600, John Dykstra wrote:
>> On Tue, 2009-03-03 at 23:10 +0000, Joao Correia wrote:
>> > I have confirmed again that the exact same commands (as on the
>> > original message), work flawlessly on 2.6.28.7 without a hitch, an=
d,
>> > AFAIK, work as intended. I have also tried the latest 2.6.29-rc6-g=
it7
>> > and it still fails like on git6.
>>
>> I have also reproduced this on Linus' latest 2.6.29-rc6 tree, using =
tc
>> version iproute2-ss071016 and a kernel config with all traffic contr=
ol
>> features enabled.
>>
>> The error reported by tc comes from the kernel-level check added by:
>>
>> =A0 =A0 =A0 commit c1b56878fb68e9c14070939ea4537ad4db79ffae
>> =A0 =A0 =A0 Author: Stephen Hemminger <shemminger@vyatta.com>
>> =A0 =A0 =A0 Date: =A0 Tue Nov 25 21:14:06 2008 -0800
>>
>> =A0 =A0 =A0 tc: policing requires a rate estimator
>>
>> =A0 =A0 Found that while trying average rate policing, it was possib=
le to
>> =A0 =A0 request average rate policing without a rate estimator. This=
 results
>> =A0 =A0 in no policing which is harmless but incorrect.
>>
>> =A0 =A0 Since policing could be setup in two steps, need to check
>> =A0 =A0 in the kernel.
>>
>> =A0 =A0 Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> =A0 =A0 Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> I got the same error when using the tc version iproute2-ss090115 bui=
lt
>> this evening from the public git repository.
>>
>> =A0 -- John
>>
>
> Very nice diagnose, thanks!
> Jarek P.
>
> PS: after upgrading iproute I couldn't reproduce this seemingly OK
> test with older versions anymore...
>
> ------------------->
> pkt_sched: act_police: Fix a rate estimator test.
>
> A commit c1b56878fb68e9c14070939ea4537ad4db79ffae "tc: policing requi=
res
> a rate estimator" introduced a test which invalidates previously work=
ing
> configs, based on examples from iproute2: doc/actions/actions-general=
=2E
> This is too rigorous: a rate estimator is needed only when police's
> "avrate" option is used.
>
> Reported-by: Joao Correia <joaomiguelcorreia@gmail.com>
> Diagnosed-by: John Dykstra <john.dykstra1@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>
> =A0net/sched/act_police.c | =A0 13 ++++++-------
> =A01 files changed, 6 insertions(+), 7 deletions(-)
>
> diff --git a/net/sched/act_police.c b/net/sched/act_police.c
> index 5c72a11..f8f047b 100644
> --- a/net/sched/act_police.c
> +++ b/net/sched/act_police.c
> @@ -183,13 +183,6 @@ override:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (R_tab =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto failure;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!est && (ret =3D=3D ACT_P_CREATED |=
|
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!gen_estimat=
or_active(&police->tcf_bstats,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&police->tcf_rate_est))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failure;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (parm->peakrate.rate) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0P_tab =3D qdisc_get_rt=
ab(&parm->peakrate,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 tb[TCA_POLICE_PEAKRATE]);
> @@ -205,6 +198,12 @@ override:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0&police->tcf_lock, est);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto failure_unlock;
> + =A0 =A0 =A0 } else if (tb[TCA_POLICE_AVRATE] &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ret =3D=3D ACT_P_CREATED ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !gen_estimator_active(&police->=
tcf_bstats,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 &police->tcf_rate_est))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failure_unlock;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* No failure allowed after this point */
>
