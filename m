From: Jiri Pirko <jiri@resnulli.us>
Subject: Qdisc->u32_node - licence to kill
Date: Mon, 7 Aug 2017 18:41:00 +0200
Message-ID: <20170807164100.GK2085@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:35918 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdHGQlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 12:41:03 -0400
Received: by mail-wr0-f175.google.com with SMTP id y43so3775761wrd.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 09:41:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal/Cong/David/all.

Digging in the u32 code deeper now. I need to get rid of tp->q for shared
blocks, but I found out about this:

struct Qdisc {
	......
        void                    *u32_node;
	......
};

Yeah, ugly. u32 uses it to store some shared data, tp_c. It actually
stores a linked list of all hashtables added to one qdiscs.

So basically what you have is, you have 1 root ht per prio/pref. Then
you can have multiple hts, linked from any other ht, does not matter in
which prio/pref they are.

Do I understand that correctly that prio/pref only has meaning if
linking does not take place, because if there is linking, the prio/pref
of inserted rule is simply ignored?

That is the most confusing thing I saw in net/sched/ so far. 
Is this a bug? Sounds like one.

Did someone introduce *u32_node (formerly static struct tc_u_common
*u32_list;) just to allow this weirdness?

Can I just remove this shared tp_c and make the linking to other
hashtables only possible within the same prio/pref? That would make
sense to me.

Thanks.

Jiri
