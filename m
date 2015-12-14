From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Tue, 15 Dec 2015 02:29:53 +0900
Message-ID: <1450114197-73779-1-git-send-email-lorenzo@google.com>
References: <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34017 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746AbbLNRaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 12:30:07 -0500
Received: by pfbo64 with SMTP id o64so30021147pfb.1
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 09:30:06 -0800 (PST)
In-Reply-To: <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a an updated version. The external behaviour of this
patchset is the same as v4; for more details, see that cover
letter at http://www.spinics.net/lists/netdev/msg354303.html .

This version fixes two bugs spotted by Eric, and implements Tom's
suggestion of making the socket destroy code a per-protocol
function pointer so that in-kernel callers can use it. The
resulting code is a bit longer but a bit more generic, and
exposes fewer TCP implementation details.

The operation is still called SOCK_DESTROY, but given that its
main implementation is the TCP ABORT operation, and that the
word "destroy" is used in the inet_csk code to refer to freeing
a socket, and in the inet_diag code to refer to broadcasts about
sockets being freed, perhaps it could be renamed to SOCK_ABORT.

Tested using net_test. Tests check that TCP resets are sent in
the right states, that accept(), read() and connect() are
interrupted, that closing sockets makes the socket unusable,
and that destroying non-TCP sockets returns EOPNOTSUPP. Tests
at https://android-review.googlesource.com/#/c/187491/ .
