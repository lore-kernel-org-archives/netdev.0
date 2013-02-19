From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SOCK_STREAM TCP: send() returns success even when other side
 responded with RST packet
Date: Tue, 19 Feb 2013 07:27:26 -0800
Message-ID: <1361287646.19353.131.camel@edumazet-glaptop>
References: <2084007858.1889873.1361286562542.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tomas Hozza <thozza@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46912 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933085Ab3BSP13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 10:27:29 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so2299735pbc.39
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 07:27:28 -0800 (PST)
In-Reply-To: <2084007858.1889873.1361286562542.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 10:09 -0500, Tomas Hozza wrote:

> I'm using TCP because it should guarantee that my data were delivered or
> let me know there was some problem. If this is not a bug, then it is at least
> confusing for TCP.

Note that a write() on a regular file descriptor has same semantic :
By default, there is no guarantee data is written on stable storage.

> 
> > To make sure data is delivered, you need additional logic.
> 
> To be honest I didn't find any way how to get notified there was a RST packet
> sent as a reply to my previously sent data.

Well, I suggest you read the man pages and some books, as this is well
explained, you are not the first guy wanting to exchange data using TCP.

man 7 socket

       SO_LINGER
              Sets or gets the SO_LINGER option.  The argument is a linger structure.

                  struct linger {
                      int l_onoff;    /* linger active */
                      int l_linger;   /* how many seconds to linger for */
                  };

              When enabled, a close(2) or shutdown(2) will not return until all queued messages
              for  the  socket  have  been  successfully  sent  or  the linger timeout has been
              reached.  Otherwise, the call returns immediately and the closing is done in  the
              background.   When  the socket is closed as part of exit(2), it always lingers in
              the background.

man 2 shutdown
...
