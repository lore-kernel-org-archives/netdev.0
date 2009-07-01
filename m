From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: Unix socket sendpage
Date: Wed, 1 Jul 2009 09:32:40 +0300
Message-ID: <b25312890906302332t10bc4cd0kf465c9e9afa04590@mail.gmail.com>
References: <200906291513.30426.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:61493 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbZGAGh6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 02:37:58 -0400
Received: by fxm18 with SMTP id 18so580875fxm.37
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 23:37:59 -0700 (PDT)
In-Reply-To: <200906291513.30426.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
  This is just a wild guess: maybe it has to do with that
 sendfile()  is for copying  data between one file descriptor and
another; sendfile() invokes sendpage() of the corresponding protocol.

With AF_UNIX sockets, which are IPC mechanism,  you can pass file
descriptors from one process to another
using control messages (ancillary data).
You can do it with SCM_RIGHTS type control message. (the msg_control
of msg should point to a cmsghdr with SCM_RIGHTS as its cmsg_type)

Just want to reiterate that I am not sure about it.

Regards,
Rami Rosen



2009/6/29 Rémi Denis-Courmont <remi.denis-courmont@nokia.com>:
>
>        Hello,
>
> Am I unaware of some fundamental reasons why AF_UNIX sockets do not support
> sendpage(splice)? or is it just that nobody bothered to write the code?
>
> --
> Rémi Denis-Courmont
> Nokia Devices R&D, Maemo Software, Helsinki
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
