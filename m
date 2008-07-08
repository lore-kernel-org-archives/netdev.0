From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: setsockopt()
Date: Mon, 7 Jul 2008 18:17:08 -0700
Message-ID: <1e41a3230807071817h106a0130ib3c78b91552f6a6@mail.gmail.com>
References: <48725DFE.6000504@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jim Rees" <rees@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: "Olga Kornievskaia" <aglo@citi.umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:21254 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319AbYGHBRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 21:17:09 -0400
Received: by an-out-0708.google.com with SMTP id d40so465972and.103
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 18:17:08 -0700 (PDT)
In-Reply-To: <48725DFE.6000504@citi.umich.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 7, 2008 at 11:18 AM, Olga Kornievskaia <aglo@citi.umich.edu> wrote:
>   Can somebody advise us on how to properly set send/receive buffer sizes
> for the NFSD in the kernel such that (1) the window is not bound by the
> TCP's default sysctl value and (2) if it is possible to do so for the accept
> sockets and not the listening socket.

As others have said, most likely you'd be better off without calling
SO_{SND,RCV}BUF.  It's possible but difficult in some circumstances to
do better than the kernel's autotuning.

If you must do SO_RCVBUF, you also need to set TCP_WINDOW_CLAMP.  It
would probably be better if the kernel would recalculate window_clamp
on an SO_RCVBUF automatically, though this is slightly problematic
from a layering point of view.  Note, however, that changing SO_RCVBUF
after connection establishment is not supported on many OS's, and
usually isn't what you want to do.

  -John
