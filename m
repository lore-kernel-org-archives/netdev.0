From: Andy Lutomirski <luto@amacapital.net>
Subject: Why ECONNREFUSED from unix_dgram_sendmsg?
Date: Thu, 11 Sep 2014 08:11:38 -0700
Message-ID: <CALCETrUM1P0Sydps_4-5yPBOBD35zOcpACv-OX8b==xT0BC1xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:38359 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998AbaIKPMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 11:12:03 -0400
Received: by mail-la0-f49.google.com with SMTP id pv20so2440122lab.8
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 08:11:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What is unix_dgram_sendmsg trying to tell me here?

        if (sock_flag(other, SOCK_DEAD)) {
                /*
                 *      Check with 1003.1g - what should
                 *      datagram error
                 */
                unix_state_unlock(other);
                sock_put(other);

                err = 0;
                unix_state_lock(sk);
                if (unix_peer(sk) == other) {
                        unix_peer(sk) = NULL;
                        unix_state_unlock(sk);

                        unix_dgram_disconnected(sk, other);
                        sock_put(other);
                        err = -ECONNREFUSED;

I'm getting this intermittently on a seqpacket socket when the other
end dies.  Shouldn't this be -ECONNRESET?

git blame doesn't tell me anything here -- this code predates git.

--Andy
