From: Kevin Smith <kevin.smith@elecsyscorp.com>
Subject: Re: [PATCH net-next 7/9] net: dsa: mv88e6xxx: restore VLANTable map
 control
Date: Fri, 26 Feb 2016 22:47:38 +0000
Message-ID: <56D0D606.2010605@elecsyscorp.com>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1456510568-13679-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <56D0B964.4090002@elecsyscorp.com> <20160226210419.GA1560@lunn.ch>
 <87d1rj6tlo.fsf@ketchup.mtl.sfl> <56D0CDCD.2040806@elecsyscorp.com>
 <20160226223516.GC1560@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s12p02o145.mxlogic.net ([208.65.145.68]:58885 "EHLO
	s12p02o145.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933420AbcBZWrw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 17:47:52 -0500
In-Reply-To: <20160226223516.GC1560@lunn.ch>
Content-Language: en-US
Content-ID: <DCBEFA09234A8B4B97EA14AE5560FB4B@dciincorporated.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 02/26/2016 04:35 PM, Andrew Lunn wrote:
> On Fri, Feb 26, 2016 at 10:12:28PM +0000, Kevin Smith wrote:
>> Hi Vivien, Andrew,
>>
>> On 02/26/2016 03:37 PM, Vivien Didelot wrote:
>>> Here, 5 is the CPU port and 6 is a DSA port.
>>>
>>> After joining ports 0, 1, 2 in the same bridge, we end up with:
>>>
>>> Port  0  1  2  3  4  5  6
>>>     0   -  *  *  -  -  *  *
>>>     1   *  -  *  -  -  *  *
>>>     2   *  *  -  -  -  *  *
>>>     3   -  -  -  -  -  *  *
>>>     4   -  -  -  -  -  *  *
>>>     5   *  *  *  *  *  -  *
>>>     6   *  *  *  *  *  *  -
>> The case I am concerned about is if the switch connected over DSA in
>> this example has a WAN port on it, which can legitimately route to the
>> CPU on port 5 but should not route to the LAN ports 0, 1, and 2.  Does
>> this VLAN allow direct communication between the WAN and LAN?  Or is
>> this prevented by DSA or some other mechanism?
> A typical WIFI access point with a connection to a cable modem.
>
> So in linux you have interfaces like
>
> lan0, lan1, lan2, lan3, wan0
>
> DSA provides you these interface. And by default they are all
> separated. There is no path between them. You can consider them as
> being separate physical ethernet cards, just like all other interfaces
> in linux.
>
> What you would typically do is:
>
> brctl addbr br0
> brctl addif br0 lan0
> brctl addif br0 lan1
> brctl addif br0 lan2
> brctl addif br0 lan3
>
> to create a bridge between the lan ports. The linux kernel will then
> push this bridge configuration down into the hardware, so the switch
> can forward frames between these ports.
>
> The wan port is not part of the bridge, so there is no L2 path to the
> WAN port. You need to do IP routing on the CPU.
>
> Linux takes the stance that switch ports interfaces should act just
> like any other linux interface and you configure them in the normal
> linux way.
>
>      Andrew

Thanks for the explanation.  I am a bit befuddled by the combination of 
all the possible configurations of the switch and how they interact with 
Linux.  :)  I think I understand what is happening now.

Kevin
