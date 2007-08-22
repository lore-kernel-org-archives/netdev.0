From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: Oops in e100_up
Date: Wed, 22 Aug 2007 13:47:23 -0300
Message-ID: <20070822164723.GT10392@ghostprotocols.net>
References: <200708220956.48297@strip-the-willow> <46CC65B8.1030006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:19591 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764214AbXHVQrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 12:47:33 -0400
Received: by wa-out-1112.google.com with SMTP id v27so245530wah
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 09:47:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <46CC65B8.1030006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Aug 22, 2007 at 09:35:04AM -0700, Kok, Auke escreveu:
> Gerrit Renker wrote:
> >With the davem-2.6.24 tree I get the following Oops in the e100 driver 
> >(cribbed from console):
> >
> >Code: 6c ff ff ff 8b 48 0c ba 01 00 00 00 89 f0 e8 1b f2 ff ff c7 86 9c 00 
> >00 00
> >      01 00 00 00 e9 4e ff ff ff 89 d0 e8 b3 f8 0b 00 eb 8e <0f> 0b eb fe 
> >      55 89 e5
> >      56 53 83 ec 0c 8b 98 dc 01 00 00 e8 ff b9
> >
> >EIP: e100_up+0x11d/0x121 
> >
> >SS:ESP 0068:f759ce38
> >
> >Stack: syscall_call -> sys_ioctl -> vfs_ioctl -> do_ioctl -> sock_ioctl -> 
> >inet_ioctl -> devinet_ioctl ->
> >       dev_change_flags -> dev_open -> e100_open -> oops
> >
> >The system log then goes on reporting "eth0: link up, 100Mbps, 
> >full-duplex" and hangs while trying to
> >restore the serial console state (not sure that this is related).
> 
> restore? Is this during resume from suspend or something?

This seems to have been fixed by a bug reported by akpm and fixed by
Thomas Graf, check a recent post with "netconsole" on the subject.

- Arnaldo
