From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2 v2] usbnet: fix bad header length bug
Date: Mon, 10 Feb 2014 14:05:20 +0100
Message-ID: <87iosn86en.fsf@nemi.mork.no>
References: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
	<1392014458.21271.6.camel@linux-fkkt.site>
	<20140210115812.GA4278@lianli>
	<1392034947.2082.30.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Emil Goode <emilgoode@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392034947.2082.30.camel@linux-fkkt.site> (Oliver Neukum's
	message of "Mon, 10 Feb 2014 13:22:27 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver@neukum.org> writes:
> On Mon, 2014-02-10 at 13:00 +0100, Emil Goode wrote:
>> On Mon, Feb 10, 2014 at 07:40:58AM +0100, Oliver Neukum wrote:
>
>> > Well, then how about simply removing the check?
>> > It seems to have outlived its usefulness.
>> >=20
>> > 	Regards
>> > 		Oliver
>> >=20
>> >
>>=20
>> I did consider that and I think it is probably the best thing to do.
>> However, I think the removal of the check could have negative effect=
s
>> on the other minidrivers, at least the qmi_wwan minidriver explicitl=
y
>> states that it is depending on this check to be made in rx_complete(=
).
>
> <censored>.

No need to do that.  I had the exact same reaction myself :-)

Anyway, I put that comment there mostly as a note to myself why the
check would be redundant at that point.  I don't see any problem with
removing the generic check in usbnet as long as we add similar checks
whereever they are needed, like in qmi_wwan.

Note that usbnet_skb_return will be one of those places.  It calls
eth_type_trans() on the skb, so it should verify that the length is at
least ETH_HLEN first.

> Oh well. But how about merging it with FLAG_MULTI_PACKET?
> I really don't want to add more flags. There is a point where enough
> flags make absurd having a common code. We are closing in on that poi=
nt.

Agreed.  I would even say we are past that point...


Bj=C3=B8rn
