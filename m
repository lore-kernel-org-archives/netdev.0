From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Gaah: selinux_socket_unix_stream_connect oops
Date: Wed, 5 Jan 2011 15:32:44 -0800
Message-ID: <AANLkTimZnqQ1xmQC2Bp3vj60uU_vPEwWi2n+G9MZ4Uo9@mail.gmail.com>
References: <AANLkTikPvJLEZetB-CbVSO0VuYLnAQz5y8D_F0HGML=5@mail.gmail.com> <20110105.142540.245404254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jeremy@goop.org, jmorris@namei.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45437 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753222Ab1AEXlP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 18:41:15 -0500
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p05NfDSA027772
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 5 Jan 2011 15:41:14 -0800
Received: by iwn9 with SMTP id 9so15757685iwn.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 15:41:13 -0800 (PST)
In-Reply-To: <20110105.142540.245404254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 5, 2011 at 2:25 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> More seriously, we can get at the struct socket via sk->sk_socket in
> the SMACK code. =A0sk->sk_socket, unlike socket->sk, has it's state
> change to NULL (via sock_orphen()) protected by unix_state_lock(),
> which we hold for "other" in this unix connect code path.
>
> Therefore I propose we fix this like so:

Looks fine to me.

And no, I don't think that selinux is all the world, but selinux is
the _common_ case, and with the cross-pointers, the only difference
can be whether you need to dereference the pointer or not - so
choosing the "extra dereference" case for the common case seems silly.

The fact that this also fixes locking is obviously an even better
reason to do it, though ;)

                      Linus
