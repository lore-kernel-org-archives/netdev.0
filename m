From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Wed, 26 Jun 2013 00:30:51 +0200
Message-ID: <51CA1A1B.5080700@xdin.com>
References: <1902752B0C92F943AB7EA9EE13E2DEEC126CC8C873@HQ1-EXCH02.corp.brocade.com> <20130624170727.4d7893a1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:54402 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195Ab3FYWay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 18:30:54 -0400
In-Reply-To: <20130624170727.4d7893a1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-06-25 02:07, Stephen Hemminger wrote:
> On Mon, 24 Jun 2013 09:44:01 -0700
> Arvid Brodin <arvid.brodin@xdin.com> wrote:
>=20
>> +
>> +
>> +static bool is_admin_up(struct net_device *dev)
>> +{
>> +       return dev && (dev->flags & IFF_UP);
>> +}
>> +
>> +static bool is_operstate_up(struct net_device *dev)
>> +{
>> +       return (dev && (dev->operstate =3D=3D IF_OPER_UP));
>> +}
>> +
>=20
> Isn't is_admin_up the same as netif_running()?

I don't think so (but I'm unsure). This is netif_running() (from includ=
e/linux/netdevice.h):

static inline bool netif_running(const struct net_device *dev)
{
	return test_bit(__LINK_STATE_START, &dev->state);
}

I'm not sure what this does. I don't think it's the same as checking wh=
ether the admin has
issued an UP command?


> And is_operstate_up the same as netif_oper_up()?

netif_oper_up() also returns true if the device state is IF_OPER_UNKNOW=
N. A device can
have that state without even having carrier, so that's not OK for the H=
SR driver.



--=20
Arvid Brodin | Consultant (Linux)
T: +46-8-56254286 | M: +46-70-9714286 | arvid.brodin@xdin.com
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
