From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero
 window is advertised
Date: Mon, 15 Sep 2014 15:43:27 -0400
Message-ID: <CADVnQym0NmF-Cqz=OEpVBmMAe6T-G1jmoq=fbVWtL7_Ny-wn3w@mail.gmail.com>
References: <54170FC0.6020907@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:52682 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792AbaIOTn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:43:29 -0400
Received: by mail-qg0-f49.google.com with SMTP id j5so4402160qga.22
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 12:43:28 -0700 (PDT)
In-Reply-To: <54170FC0.6020907@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 12:11 PM, Andrey Dmitrov
<andrey.dmitrov@oktetlabs.ru> wrote:
> It is possible to create a lot of connections in the same manner which will be in FIN_WAIT1 state forever.
...
> After ~10 minutes you will see 500 connections in the FIN_WAIT1 state on the host_A:
> netstat | grep FIN_WAIT1 | wc -l
> 500

Thanks for the report. In your tests, have you ever seen the number of
such connections exceed net.ipv4.tcp_max_orphans?

Can you set net.ipv4.tcp_max_orphans to a low value and verify that it
limits the number of such connections? AFAICT it should.

thanks,
neal
