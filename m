From: Sargun Dhillon <sargun@sargun.me>
Subject: eBPF tunable max instructions or max tail call?
Date: Mon, 11 Jul 2016 17:56:07 -0700
Message-ID: <CAMp4zn-6G+41PrsAHH3ZuKcKa-o16_d7ZEuRE517v42iA=Y-Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33379 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167AbcGLA4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 20:56:48 -0400
Received: by mail-oi0-f41.google.com with SMTP id u201so1525874oie.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 17:56:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It would be nice to have eBPF programs that are longer than 4096
instructions. I'm trying to implement XSalsa20 in eBPF, and
unfortunately, it doesn't fit into 4096 instructions since I'm
unrolling all of the loops. Further than that, doing tail calls to
process each block results in me hitting the tail call limit.

It don't think that it makes much sense to expose the crypto API as
BPF helpers, as I'm not sure if we can ensure safety, and timely
execution with it. I may be wrong here, and if there is a sane, safe
way to expose the crypto API, I'm all ears.

Other than that, it would be nice to make the max instructions a knob,
and I don't think that it has much downside, given it's only checked
on load time. It would be nice to make the tail call limit a tunable
as well, but I'm unsure of the performance impact it might have given
that it's checked at runtime.

What do y'all think is reasonable? Make them both tunable? Just one? None?
