From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [rfc] sk_write_space() for atm
Date: Tue, 24 Jun 2003 22:31:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306250233.h5P2XtsG011090@ginger.cmf.nrl.navy.mil>
References: <20030624.174042.27809957.davem@redhat.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Tue, 24 Jun 2003 17:40:42 PDT."
             <20030624.174042.27809957.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030624.174042.27809957.davem@redhat.com>,"David S. Miller" writes:
>This looks ok to me, but I am not well versed in this
>area.  For example, if you give a spurious wakeup via
>poll() what can happen?

as far as i can tell this version of poll is fairly close
to datagram_poll so therefore it must be correct :)
i would say the previous version was racy since it needed
to check vcc->reply repeatedly, which could change.  now,
sk_err is checked once and is error state of the socket.   

the only reason i dont use datagram_poll (besides
atm implementing a different writeable condition)
are atm sockets that are waiting (in connecting)
would block when written.  this is similar to a tcp
socket w/o syn having been sent.
