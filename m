From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net 0/3] nfp: wait more carefully for card init
Date: Wed, 13 Sep 2017 18:53:08 +0200
Message-ID: <20170913185308.7c64275e@cakuba.netronome.com>
References: <20170913155131.18090-1-jakub.kicinski@netronome.com>
        <20170913.093902.570914704132982694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:46970 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdIMQxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 12:53:15 -0400
Received: by mail-pg0-f49.google.com with SMTP id i130so1445970pgc.3
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 09:53:15 -0700 (PDT)
In-Reply-To: <20170913.093902.570914704132982694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Sep 2017 09:39:02 -0700 (PDT), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Wed, 13 Sep 2017 08:51:28 -0700
>=20
> > The first patch is a small fix for flower offload, we need a whitelist
> > of supported matches, otherwise the unsupported ones will be ignored.
> >=20
> > The second and the third patch are adding wait/polling to the probe pat=
h.
> > We had reports of driver failing probe because it couldn't find the=20
> > control process (NSP) on the card.  Turns out the NSP will only announce
> > its existence after it's fully initialized.  Until now we assumed it=20
> > will be reachable, just not processing commands (hence we wait for
> > a NOOP command to execute successfully). =20
>=20
> Please build test your changes and look at what the compiler says:
>=20
> drivers/net/ethernet/netronome/nfp/nfp_main.c: In function =E2=80=98nfp_f=
w_unload=E2=80=99:
> drivers/net/ethernet/netronome/nfp/nfp_main.c:395:10: warning: =E2=80=98r=
eturn=E2=80=99 with a value, in function returning void
>    return err;
>           ^~~
> drivers/net/ethernet/netronome/nfp/nfp_main.c:388:13: note: declared here
>  static void nfp_fw_unload(struct nfp_pf *pf)
>              ^~~~~~~~~~~~~

Sorry about that!
