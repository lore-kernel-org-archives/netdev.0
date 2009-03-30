From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH 1/2] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Mon, 30 Mar 2009 15:57:51 +0800
Message-ID: <2a27d3730903300057l53d3f702jb34765a95e7ec3cb@mail.gmail.com>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <2a27d3730903270350m52fcb837ge78c0b87cc3887d5@mail.gmail.com>
	 <OF073D5C49.F0D791DE-ONC1257586.0040163D-C1257586.00413F47@transmode.se>
	 <2a27d3730903300036x1dc265a3o76ea36ca6a16fb5b@mail.gmail.com>
	 <OF8F2A374C.8C3B68EA-ONC1257589.002A7868-C1257589.002AD913@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avorontsov@ru.mvista.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:10178 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbZC3H5x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 03:57:53 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2325281rvb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 00:57:51 -0700 (PDT)
In-Reply-To: <OF8F2A374C.8C3B68EA-ONC1257589.002A7868-C1257589.002AD913@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2009 at 3:48 PM, Joakim Tjernlund
<Joakim.Tjernlund@transmode.se> wrote:
> pku.leo@gmail.com wrote on 30/03/2009 09:36:21:
>>
>> On Fri, Mar 27, 2009 at 7:52 PM, Joakim Tjernlund
>> <Joakim.Tjernlund@transmode.se> wrote:
>> > pku.leo@gmail.com wrote on 27/03/2009 11:50:09:
>> >>
>> >> On Thu, Mar 26, 2009 at 8:54 PM, Joakim Tjernlund
>> >> <Joakim.Tjernlund@transmode.se> wrote:
>> >> > Also set NAPI weight to 64 as this is a common value.
>> >> > This will make the system alot more responsive while
>> >> > ping flooding the ucc_geth ethernet interaface.
>> >> >
>> >> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>> >> > ---
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Errors and other events */
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ucce & UCCE_OTHER) {
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ucce=
 & UCC_GETH_UCCE_BSY)
>> >> > @@ -3733,7 +3725,7 @@ static int ucc_geth_probe(struct of_devic=
e*
>> > ofdev, const struct of_device_id *ma
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->netdev_ops =3D &ucc_geth_netdev=
_ops;
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->watchdog_timeo =3D TX_TIMEOUT;
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_WORK(&ugeth->timeout_work, ucc_=
geth_timeout_work);
>> >> > - =C2=A0 =C2=A0 =C2=A0 netif_napi_add(dev, &ugeth->napi, ucc_ge=
th_poll,
>> > UCC_GETH_DEV_WEIGHT);
>> >> > + =C2=A0 =C2=A0 =C2=A0 netif_napi_add(dev, &ugeth->napi, ucc_ge=
th_poll, 64);
>> >>
>> >> It doesn't make sense to have larger napi budget than the size of=
 RX
>> >> BD ring. =C2=A0You can't have more BDs than RX_BD_RING_LEN in bac=
klog for
>> >> napi_poll to process. =C2=A0Increase the RX_BD_RING_LEN if you wa=
nt to
>> >> increase UCC_GETH_DEV_WEIGHT. =C2=A0However please also provide t=
he
>> >> performance comparison for this kind of change. =C2=A0Thanks
>> >
>> > Bring it up with David Miller. After my initial attempt to just
> increase
>> > weight somewhat, he requested that I hardcoded it to 64. Just read=
 the
>> > whole thread.
>> > If I don't increase weight somewhat, ping -f -l 3 almost halts the
> board.
>> > Logging
>> > in takes forever. These are my "performance numbers".
>>
>> Faster response time is surely good. =C2=A0But it might also mean CP=
U is
>> not fully loaded. =C2=A0IMHO, throughput is a more important factor =
for
>> network devices. =C2=A0When you try to optimize the driver, please a=
lso
>> consider the throughput change. =C2=A0Thanks.
>
> This particular change isn't about performance, it is about not
> "bricking" the board during heavy traffic. Next step is to optimize
> the driver.

Sure.  I mean for other changes like tx NAPI, ring size tweak and tx lo=
gic.

- Leo
