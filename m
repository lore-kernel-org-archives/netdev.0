From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Splice status
Date: Mon, 5 Jul 2010 20:08:25 +0800
Message-ID: <AANLkTikciGxxTR2a2aEASVxPp4PaHWV0BcyIPMLmRsgh@mail.gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38216 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab0GEMIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 08:08:46 -0400
Received: by vws5 with SMTP id 5so5960184vws.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 05:08:45 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 5, 2010 at 6:52 PM, Ofer Heifetz <oferh@marvell.com> wrote:
> I am using Samba, so from my understanding of the source code, it loops and performs splice(sock, pipe) and splice(pipe, fd). There is no flush of any sort in between.
>

I checked the function: sys_recvfile() and found It is buggy.

                to_write = nread;
                while (to_write > 0) {
                        int thistime;
                        thistime = splice(pipefd[0], NULL, tofd,
                                          &splice_offset, to_write,
                                          SPLICE_F_MOVE);
                        if (thistime == -1) {
                                goto done;
                        }
                        to_write -= thistime;
                }

                total_written += nread;
                count -= nread;

When splice fails, it should drain the pipe. If not, the following
splice(2) to pipe may hang, because the pipe hasn't enough space for
the data read from socket.

> When you say drain you mean to flush all data to pipe?
>

No. I means to read all the data in the pipe.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
