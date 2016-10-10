From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next 5/6] qed: Allow chance for fast ramrod
 completions
Date: Mon, 10 Oct 2016 06:33:05 +0000
Message-ID: <BL2PR07MB230613EB6D587458F4143C678DDB0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1476026738-26069-1-git-send-email-Yuval.Mintz@qlogic.com>
         <1476026738-26069-6-git-send-email-Yuval.Mintz@qlogic.com>,<1476058115.28155.282.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0043.outbound.protection.outlook.com ([104.47.32.43]:35462
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751691AbcJJGrN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 02:47:13 -0400
In-Reply-To: <1476058115.28155.282.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > +=A0=A0=A0=A0 while (iter_cnt--) {
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Validate we receive completion=
 update */
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 smp_rmb();
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (comp_done->done =3D=3D=
 1) {
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if=
 (p_fw_ret)
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 *p_fw_ret =3D comp_done->fw_return_code;
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 re=
turn 0;
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }

> Note that this smp_rmb() and accesses to ->done and ->fw_return_code are
> racy.

> fw_return_code needs to be written _before_ done.

Thanks for catching this up.

Dave  - do you want me to re-spin for this?
I believe it's a day-1 issue [not introduced by this series],
and merits its own patch [and not incorporated into this one].
Still, if you'd like me to re-spin and include Eric's fix, I'll do it.=
