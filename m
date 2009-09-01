From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 01 Sep 2009 17:58:05 +0200
Message-ID: <4A9D448D.6050309@gmail.com>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <4A9D3687.2020101@gmail.com> <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1> <4A9D3D9A.1030500@gmail.com> <alpine.DEB.1.10.0909011534350.12112@V090114053VZO-1> <4A9D410D.5000507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60915 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754578AbZIAP6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:58:13 -0400
In-Reply-To: <4A9D410D.5000507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Christoph Lameter a =E9crit :
>> On Tue, 1 Sep 2009, Eric Dumazet wrote:
>>
>>> You should see that in /proc/interrupts, if I correctly understand =
bnx2.c
>> Hmmm I have 8 interrupts:
>>
>>   62:        158          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-0
>>   63:         84          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-1
>>   64:        412          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-2
>>   65:         25          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-3
>>   66:      49718          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-4
>>   67:         65          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-5
>>   68:        686          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-6
>>   69:       2582          0          0          0          0        =
  0
>> 0          0          0          0          0          0          0
>> 0          0          0  IR-PCI-MSI-edge      eth0-7
>=20
> Yes, this confirm you have 8 queues on this NIC
>=20
> Strange thing is they seem to be all serviced by CPU-0, which is not =
good...
>=20
>=20
>=20

Given that bnx2.c uses num_online_cpus() at init time, you could
as a workaround do the insmod/modprobe bnx2 with only one online cpu,
and you'll revert to a mono-queue NIC :)

int msix_vecs =3D min(cpus + 1, RX_MAX_RINGS);=20
=2E..
if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !dis_msi && cpus > 1)
	bnx2_enable_msix(bp, msix_vecs);


=46or your multicast test anyway, only one queue should be used (one fl=
ow)


