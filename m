From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins if no
   carrier
Date: Wed, 5 Sep 2012 10:47:56 +0200
Message-ID: <OF70CDBF7F.EFE301C2-ONC1257A70.002F0D3F-C1257A70.003055BF@transmode.se>
References: <504627A4.9080306@neli.hopto.org>,	<OF61EF9E6E.9EF08C21-ONC1257A6F.004FE9B4-C1257A6F.0050A9B2@transmode.se> <OF163B52E3.E2F5ACB3-ONC1257A6F.00635561-C1257A6F.00635564@transmode.se> <50465791.40805@neli.hopto.org> <OFFA3AC1B1.08FC3AAD-ONC1257A70.00266EDC-C1257A70.0026E8BC@transmode.se> <50470DAC.8030009@neli.hopto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:58041 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758162Ab2IEIr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 04:47:59 -0400
In-Reply-To: <50470DAC.8030009@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Micha Nelissen <micha@neli.hopto.org> wrote on 2012/09/05 10:30:36:

> From: Micha Nelissen <micha@neli.hopto.org>
> To: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
> Cc: netdev@vger.kernel.org
> Date: 2012/09/05 10:30
> Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins if no   carrier
>
> Op 2012-09-05 9:04, Joakim Tjernlund schreef:
> >> Because that's where my root filesystem is? The IP autoconfiguration
> >> code exists for this purpose.
> >
> > This is not the only purpose.
>
> Documentation/filesystems/nfs/nfsroot.txt seems to suggest so (this is
> where the ip= parameter is documented), but it works independently indeed.
>
> So explain your reasons?
If you read that doc you find:

ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>

  This parameter tells the kernel how to configure IP addresses of devices
  and also how to set up the IP routing table. It was originally called
  `nfsaddrs', but now the boot-time IP configuration works independently of
  NFS, so it was renamed to `ip' and the old name remained as an alias for
  compatibility reasons.

>
> >>> The answer is probably the same, it is much easier to
> >>> manage our IP config in one place for our embedded system.
> >>
> >> You retrieve the kernel via TFTP or so when booting?
> >
> > Yes, but mostly not. This really doesn't matter
>
> Seems to me that if you boot standalone there is no reason to let the IP
> address be configured by the kernel? Retrieve the IP address in user
> space from your bootloader environment or whatever. And if you boot from
> ethernet (or some other networking interface), then you have a carrier,
> and there is no 2 minute delay (maybe less even than before with this
> patch!).

Everything is possible but we choosed to use already built-in functionality, as
did you.
You could have added an initram FS and done your NFS mount there so this
argument goes nowhere.

>
> >>> The wait should be conditional on NFS root or not so that non NFS roots
> >>> can skip this stage altogether.
> >
> > Your patch broke other use cases so my patch would just revert or change the tmo
> > to 2 secs or so.
> > Or you could clean up your stuff so it works for all and not just for you.
>
> It didn't break anything, it does work for you also, you just need to
> wait somewhat longer. Or make sure there is a carrier. The intent of the
> original 1 second delay was to let the link come up!

Sure it did, our system(and not only ours I bet) can not accept a 2 minute delay in
booting up the system for no reason.

Please adjust the 2 min wait to nfsroot= only and keep the old way for ip=

 Jocke
