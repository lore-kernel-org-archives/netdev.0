From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 3 Dec 2015 01:30:48 +0900
Message-ID: <CAKD1Yr1vsdrxb6YvOB3bbxuLso+hniexWDciOeWvv1fnyfYP1w@mail.gmail.com>
References: <CAHo-OoyN7OgvHSuXxjk7C4FitXhoWffOxY1wkQBWwi+nc013_w@mail.gmail.com>
 <1448937147-38043-1-git-send-email-lorenzo@google.com> <CALx6S36fb7C9-LCo5egFZyOo1mZ1A9kHN6xpgNUUQS=njQ8Y-g@mail.gmail.com>
 <CAKD1Yr2qyKCmfo75+OpsfqrUoFquXiA_GqwVr_BsU1AW5MmPbQ@mail.gmail.com> <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34390 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932798AbbLBQbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 11:31:09 -0500
Received: by ykfs79 with SMTP id s79so53182596ykf.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 08:31:09 -0800 (PST)
In-Reply-To: <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 1:12 AM, Tom Herbert <tom@herbertland.com> wrote:
> The in kernel caller would already have a pointer to the socket so the
> call would just be sk->sk_prot->destroy(sk). That call should make its
> way down to same backend function in TCP that the diag path would use.
> We need this in the kernel for the same reasons you want this in
> userspace, if a third party hits an unrecoverable error on the socket
> it needs to signal this condition to the owner of the socket but can't
> actually close the socket (useful to RDS, KCM, probably
> TLS-in-kernel).

Oh, I see, yes. You're thinking of a case where multiple protocols
support this destroy operation. An in-kernel caller has a pointer to a
sk that it wants to unwedge, but doesn't need to know which destroy
function to use for which protocol, it just does "if
(sk->sk_prot->destroy != NULL) sk->sk_prot_destroy(sk)". I think that
should be a trivial change on top of what I have.
