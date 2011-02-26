From: Jesse Gross <jesse@nicira.com>
Subject: Re: TX VLAN acceleration on bridges broken in 2.6.37?
Date: Fri, 25 Feb 2011 17:16:35 -0800
Message-ID: <AANLkTikVvjsaG94-gtauvTLjH_RW5fmva8+N7Lk-ryQ0@mail.gmail.com>
References: <20110221232902.GA3440@x61s.reliablesolutions.de>
	<AANLkTinoJqWA6ffnUx2KW_83srNbo+k6r24hnNpPTGvW@mail.gmail.com>
	<20110226001908.GA10777@x61s.reliablesolutions.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Jan Niehusmann <jan@gondor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54229 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab1BZBQg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 20:16:36 -0500
In-Reply-To: <20110226001908.GA10777@x61s.reliablesolutions.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 4:19 PM, Jan Niehusmann <jan@gondor.com> wrote:
> On Fri, Feb 25, 2011 at 02:53:21PM -0800, Jesse Gross wrote:
>> is specific to the e1000e driver. =A0I know that some other Intel NI=
Cs
>> require vlan stripping on receive to be enabled for vlan insertion o=
n
>> transmit to work. =A0Since this driver has not been converted over t=
o
>> use the new vlan model yet, it only enables these things if a vlan i=
s
>> directly configured on it. =A0To confirm this can you try a few thin=
gs:
>
> My observations confirm your theory:

OK, thanks for confirming.  The right solution is convert the driver
over to the new vlan model.  I don't know how soon I might get to
this, maybe it's something that the Intel guys can take a look at?

> - indeed, -e is necessary to show the vlan tags. So my prior observat=
ion
> =A0regarding tag visibility in tcpdump was wrong. The packets are sti=
ll
> =A0have a vlan tag in the non-working case.
>
> =A0(What actually is affected by the txvlan flag is the ability to fi=
lter
> =A0for vlan tags with tcpdump. =A0so 'tcpdump -e -i eth0' shows the p=
ackets,
> =A0'tcpdump -e -i eth0 vlan' only shows them with txvlan off. However=
,
> =A0filtering for the vlan tag also doesn't work with the vlan interfa=
ce
> =A0on eth0.1, while the tagging actually works, as verified above.)

Good to know, though that's a separate issue.
