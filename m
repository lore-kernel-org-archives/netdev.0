From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v2] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Mon, 8 Jul 2013 17:54:55 +0200
Message-ID: <51DAE0CF.4080905@xdin.com>
References: <51CB05BB.3030909@xdin.com> <20130628.211632.1064715548223073397.davem@davemloft.net> <51D2156A.3070403@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>,
	<joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:52653 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549Ab3GHQFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jul 2013 12:05:21 -0400
In-Reply-To: <51D2156A.3070403@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-07-02 01:48, Arvid Brodin wrote:
> On 2013-06-29 06:16, David Miller wrote:
>> From: Arvid Brodin <arvid.brodin@xdin.com>
>> Date: Wed, 26 Jun 2013 17:16:11 +0200
>>
>>> +static int hsr_dev_open(struct net_device *dev)
>>> +{
>>> +    struct hsr_priv *hsr_priv;
>>> +
>>> +    hsr_priv =3D netdev_priv(dev);
>>> +
>>> +    if (hsr_priv->slave[0])
>>> +        dev_open(hsr_priv->slave[0]);
>>> +    if (hsr_priv->slave[1])
>>> +        dev_open(hsr_priv->slave[1]);
>>> +
>>> +    return 0;
>>> +}
>>
>> dev_open() can and does fail, you must thus check for error returns,=
 undo any
>> necessary state, and propagate that error to callers of hsr_dev_open=
=2E
>>
>
> I'm not sure it's an error (from the HSR interface's point of view) i=
f the slave(s)
> won't come up here. The calls to dev_open() can be seen more like a c=
onvenience
> than a necessity (I actually left them out to begin with). If none of=
 the slaves
> could go up the HSR interface would end up as admin UP but with opers=
tate
> IF_OPER_LOWERLAYERDOWN until any of the slaves went up.
>
> I see that the VLAN code, in its vlan_dev_open(), checks the underlyi=
ng interface's
> IFF_UP flag and returns -ENETDOWN if it's not set. That might be an o=
ption here -
> but then one would have to set three interfaces up to get a working H=
SR interface,
> which is a bit tedious... Also, the HSR interface could end up in the=
 state above
> anyway if both slaves went down after the HSR interface went up succe=
ssfully.
>
> What about checking the return values and printing a warning if a sla=
ve dev_open()
> fails, but still return success for the HSR interface no matter what?
>


Is there anything else I can do to get this patch accepted? Anything th=
at's missing
or done incorrectly that I need to fix?


--=20
Arvid Brodin | Consultant (Linux)
T: +46-8-56254286 | M: +46-70-9714286 | arvid.brodin@xdin.com
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
