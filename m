From: Amir Vadai <amirv@mellanox.com>
Subject: Re: Manual loading of mlx4_en
Date: Wed, 30 Jul 2014 10:56:23 +0300
Message-ID: <53D8A527.1070506@mellanox.com>
References: <1406627612.4498.16.camel@chaos.site> <53D7748A.6040800@mellanox.com> <20140729123405.6802fbc4@endymion.delvare> <53D77B26.3070905@mellanox.com> <1406635578.4498.18.camel@chaos.site> <53D7A4C0.8090004@mellanox.com> <20140730021400.GA25996@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean Delvare <jdelvare@suse.de>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"Jack Morgenstein" <jackm@dev.mellanox.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:51845 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbaG3H4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 03:56:31 -0400
In-Reply-To: <20140730021400.GA25996@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/2014 5:14 AM, Benjamin Poirier wrote:
> On 2014/07/29 16:42, Amir Vadai wrote:
>> On 7/29/2014 3:06 PM, Jean Delvare wrote:
>>> Le Tuesday 29 July 2014 =E0 13:44 +0300, Amir Vadai a =E9crit :
>>>> On 7/29/2014 1:34 PM, Jean Delvare wrote:
>>>>> Many thanks for the fast and detailed answer! I'll go backport th=
is
>>>>> commit to kernel 3.12 (and 3.0, hopefully it doesn't have too man=
y
>>>>> dependencies?)
>>>>
>>>> I don't think there is any dependency for that commit. If you're
>>>> backporting it, also take a small fix to it:
>>>> f24f790 net/mlx4_core: Load the Eth driver first
>>>
>>> Thanks for the hint. I suppose I should pick 7855bff4 "net/mlx4_cor=
e:
>>> Load the IB driver when the device supports IBoE" as well?
>>>
>> Right - missed it.
>=20
> Thanks for the pointers.
> Looking at f24f790f, I'm wondering if request_module(EN_DRV_NAME) oug=
ht
> to be used instead of _nowait to guarantee the desired effect. Suppos=
e
> for example that the process is migrated to a different cpu between t=
he
> two request_module calls, the second one could complete before the fi=
rst
> one no?
>=20

The issue was addressed after the commit above, through these two
commits in a proper and robust way:
9433c18 IB/mlx4: Invoke UPDATE_QP for proxy QP1 on MAC changes
ce8d9e0 net/mlx4_core: Add UPDATE_QP SRIOV wrapper support

Thanks,
Amir
