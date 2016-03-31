From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 0/8] add TX timestamping via cmsg
Date: Wed, 30 Mar 2016 23:50:31 -0400
Message-ID: <CAF=yD-Lpx2nBq1bL64-pzOqHh5E-a4Bbr2goDE59ApWvzFri_Q@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
 <20160331003744.GA3300@kafai-mba.local> <CADAM+B1osNNwVpg1R_kAFW8m75mr15_usDa=gmqpBA+xwyA_fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f195.google.com ([209.85.217.195]:33134 "EHLO
	mail-lb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684AbcCaDvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 23:51:13 -0400
Received: by mail-lb0-f195.google.com with SMTP id bc4so5815813lbc.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 20:51:12 -0700 (PDT)
In-Reply-To: <CADAM+B1osNNwVpg1R_kAFW8m75mr15_usDa=gmqpBA+xwyA_fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Nice patches!

This does not yet solve the append issue that your MSG_EOR patch
addresses, of course.

The straightforward jump to new_segment that I proposed as
simplification is more properly a "start-of-record" than
"end-of-record" signal. It is probably preferable to indeed be able to
pass EOR as signal that the last skb must not be appended to in
subsequent calls.

I think that the record bounds issue is best solved independently from
the interface for intermittent timestamps because (a) changing the tcp
bytestream packetization for timestamping introduces subtle
differences between tracked and untracked data that are not always
acceptable and (b) EOR can also be useful outside timestamps. A
zerocopy sendmsg patchset that I sent for RFC last year encountered a
similar requirement, to give one example: each skb with user data must
point to a completion notification structure (ubuf_info), and can only
point to one at a time. Appends that cause a conflict in skb->uarg
pointers had to be blocked, at the cost of possibly different
packetization compared to regular sends.
