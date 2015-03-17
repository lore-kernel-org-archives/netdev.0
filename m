From: Cong Wang <cwang@twopensource.com>
Subject: Re: Possible bug in tc tool or kernel
Date: Tue, 17 Mar 2015 13:42:54 -0700
Message-ID: <CAHA+R7O__y1_czX74Ga1RSU-x8X0hUhs2Z01=vo37QUVkNniKQ@mail.gmail.com>
References: <5507FA88.60303@eqv.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?0KHQvtC70L7QstGM0LXQsiDQodC10YDQs9C10Lk=?= <sol@eqv.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33769 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbbCQUmz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 16:42:55 -0400
Received: by iecvj10 with SMTP id vj10so22243938iec.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 13:42:54 -0700 (PDT)
In-Reply-To: <5507FA88.60303@eqv.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 2:57 AM, =D0=A1=D0=BE=D0=BB=D0=BE=D0=B2=D1=8C=D0=
=B5=D0=B2 =D0=A1=D0=B5=D1=80=D0=B3=D0=B5=D0=B9 <sol@eqv.ru> wrote:
> Hi!
>
> I'm sol sorry, but English in not my native language.
>
> After upgrade kernel  tc lost some u32 filters
>
> example: where is a "match ip dst 10.10.0.0/24" entries?
>

Can you check if the following commit fixes your problem?

It is already merged in stable kernel, you probably need to
wait for a newer Fedora kernel release if it has included it.

commit b057df24a7536cce6c372efe9d0e3d1558afedf4
Author: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communications.fr>
Date:   Tue Feb 3 19:05:18 2015 +0100

    cls_api.c: Fix dumping of non-existing actions' stats.

    In tcf_exts_dump_stats(), ensure that exts->actions is not empty be=
fore
    accessing the first element of that list and calling tcf_action_cop=
y_stats()
    on it.  This fixes some random segvs when adding filters of type
"basic" with
    no particular action.

    This also fixes the dumping of those "no-action" filters, which mor=
e often
    than not made calls to tcf_action_copy_stats() fail and consequentl=
y netlink
    attributes added by the caller to be removed by a call to nla_nest_=
cancel().

    Fixes: 33be62715991 ("net_sched: act: use standard struct list_head=
")
    Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communic=
ations.fr>
    Acked-by: Cong Wang <cwang@twopensource.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
