From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH 1/2] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Mon, 30 Mar 2009 15:36:21 +0800
Message-ID: <2a27d3730903300036x1dc265a3o76ea36ca6a16fb5b@mail.gmail.com>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <2a27d3730903270350m52fcb837ge78c0b87cc3887d5@mail.gmail.com>
	 <OF073D5C49.F0D791DE-ONC1257586.0040163D-C1257586.00413F47@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avorontsov@ru.mvista.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:2679 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbZC3HgX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 03:36:23 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2316946rvb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 00:36:21 -0700 (PDT)
In-Reply-To: <OF073D5C49.F0D791DE-ONC1257586.0040163D-C1257586.00413F47@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2009 at 7:52 PM, Joakim Tjernlund
<Joakim.Tjernlund@transmode.se> wrote:
> pku.leo@gmail.com wrote on 27/03/2009 11:50:09:
>>
>> On Thu, Mar 26, 2009 at 8:54 PM, Joakim Tjernlund
>> <Joakim.Tjernlund@transmode.se> wrote:
>> > Also set NAPI weight to 64 as this is a common value.
>> > This will make the system alot more responsive while
>> > ping flooding the ucc_geth ethernet interaface.
>> >
>> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>> > ---
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Errors and other events */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ucce & UCCE_OTHER) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ucce & =
UCC_GETH_UCCE_BSY)
>> > @@ -3733,7 +3725,7 @@ static int ucc_geth_probe(struct of_device*
> ofdev, const struct of_device_id *ma
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->netdev_ops =3D &ucc_geth_netdev_op=
s;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->watchdog_timeo =3D TX_TIMEOUT;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_WORK(&ugeth->timeout_work, ucc_get=
h_timeout_work);
>> > - =C2=A0 =C2=A0 =C2=A0 netif_napi_add(dev, &ugeth->napi, ucc_geth_=
poll,
> UCC_GETH_DEV_WEIGHT);
>> > + =C2=A0 =C2=A0 =C2=A0 netif_napi_add(dev, &ugeth->napi, ucc_geth_=
poll, 64);
>>
>> It doesn't make sense to have larger napi budget than the size of RX
>> BD ring. =C2=A0You can't have more BDs than RX_BD_RING_LEN in backlo=
g for
>> napi_poll to process. =C2=A0Increase the RX_BD_RING_LEN if you want =
to
>> increase UCC_GETH_DEV_WEIGHT. =C2=A0However please also provide the
>> performance comparison for this kind of change. =C2=A0Thanks
>
> Bring it up with David Miller. After my initial attempt to just incre=
ase
> weight somewhat, he requested that I hardcoded it to 64. Just read th=
e
> whole thread.
> If I don't increase weight somewhat, ping -f -l 3 almost halts the bo=
ard.
> Logging
> in takes forever. These are my "performance numbers".

=46aster response time is surely good.  But it might also mean CPU is
not fully loaded.  IMHO, throughput is a more important factor for
network devices.  When you try to optimize the driver, please also
consider the throughput change.  Thanks.

- Leo
