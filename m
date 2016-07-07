From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net/ixgbe: Allow resetting VF admin mac to zero
Date: Thu, 7 Jul 2016 08:38:24 -0700
Message-ID: <CAKgT0UeYdRAo8F7QsKMn1Wws0Psvy6aXCCE7Ms0qdJ5B-PDSyg@mail.gmail.com>
References: <1467364778-27198-1-git-send-email-juerg.haefliger@hpe.com> <20160706205721.15eae36c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Juerg Haefliger <juerg.haefliger@hpe.com>,
	Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160706205721.15eae36c@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 6, 2016 at 8:57 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri,  1 Jul 2016 11:19:38 +0200
> Juerg Haefliger <juerg.haefliger@hpe.com> wrote:
>
>> The VF administrative mac addresses (stored in the PF driver) are
>> initialized to zero when the PF driver starts up.
>>
>> These addresses may be modified in the PF driver through ndo calls
>> initiated by iproute2 or libvirt.
>>
>> While we allow the PF/host to change the VF admin mac address from zero
>> to a valid unicast mac, we do not allow restoring the VF admin mac to
>> zero. We currently only allow changing this mac to a different unicast mac.
>>
>> This leads to problems when libvirt scripts are used to deal with
>> VF mac addresses, and libvirt attempts to revoke the mac so this
>> host will not use it anymore.
>>
>> Fix this by allowing resetting a VF administrative MAC back to zero.
>>
>> Implementation and commit message shamelessly stolen from:
>> commit 6e5224224faa ("net/mlx4_core: Allow resetting VF admin mac to zero")
>>
>> Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
>
> Since set mac is allowed any time even when device is up, you must
> prevent a a device that is in UP state from having all zero MAC address.

I'm pretty sure the actual MAC address of the VF does not change in
such a case, it should retain the last MAC address it was given from
the PF and report link down until a new one is assigned.

- Alex
