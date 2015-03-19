From: =?UTF-8?B?0KHQvtC70L7QstGM0LXQsiDQodC10YDQs9C10Lk=?= <sol@eqv.ru>
Subject: Re: Possible bug in tc tool or kernel
Date: Thu, 19 Mar 2015 17:45:30 +0300
Message-ID: <550AE10A.5080604@eqv.ru>
References: <5507FA88.60303@eqv.ru> <CAHA+R7O__y1_czX74Ga1RSU-x8X0hUhs2Z01=vo37QUVkNniKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.deltelecom.ru ([195.54.177.82]:48160 "EHLO
	ns2.deltelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbbCSO4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 10:56:39 -0400
In-Reply-To: <CAHA+R7O__y1_czX74Ga1RSU-x8X0hUhs2Z01=vo37QUVkNniKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

17.03.2015 23:42, Cong Wang =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, Mar 17, 2015 at 2:57 AM, =D0=A1=D0=BE=D0=BB=D0=BE=D0=B2=D1=8C=
=D0=B5=D0=B2 =D0=A1=D0=B5=D1=80=D0=B3=D0=B5=D0=B9 <sol@eqv.ru> wrote:
>> Hi!
>>
>> I'm sol sorry, but English in not my native language.
>>
>> After upgrade kernel  tc lost some u32 filters
>>
>> example: where is a "match ip dst 10.10.0.0/24" entries?
>>
> Can you check if the following commit fixes your problem?
>
> It is already merged in stable kernel, you probably need to
> wait for a newer Fedora kernel release if it has included it.
>
> commit b057df24a7536cce6c372efe9d0e3d1558afedf4
> Author: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communications.fr=
>
> Date:   Tue Feb 3 19:05:18 2015 +0100
>
>      cls_api.c: Fix dumping of non-existing actions' stats.
>
>      In tcf_exts_dump_stats(), ensure that exts->actions is not empty=
 before
>      accessing the first element of that list and calling tcf_action_=
copy_stats()
>      on it.  This fixes some random segvs when adding filters of type
> "basic" with
>      no particular action.
>
>      This also fixes the dumping of those "no-action" filters, which =
more often
>      than not made calls to tcf_action_copy_stats() fail and conseque=
ntly netlink
>      attributes added by the caller to be removed by a call to nla_ne=
st_cancel().
>
>      Fixes: 33be62715991 ("net_sched: act: use standard struct list_h=
ead")
>      Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-commu=
nications.fr>
>      Acked-by: Cong Wang <cwang@twopensource.com>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Checked. This patch is applied to my kernel and not fixes this problem.

tc as part of iproute2 freshed to latest 3.19.0 version, but nothing...
