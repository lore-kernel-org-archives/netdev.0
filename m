From: Ian Jeffray <ian@jeffray.co.uk>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Wed, 16 Jul 2008 08:30:16 +0100
Message-ID: <487DA388.3030104@jeffray.co.uk>
References: <487CD7A7.2080800@jeffray.co.uk> <487D893A.5080207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out5.blueyonder.co.uk ([195.188.213.8]:52035 "EHLO
	smtp-out5.blueyonder.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751618AbYGPHaV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 03:30:21 -0400
In-Reply-To: <487D893A.5080207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for directing me to a better list.

=46urther responses below:

Eric Dumazet wrote:
> CC to netdev where this report might find better answers
>=20
> Ian Jeffray a =E9crit :
>> All,
>>
>> I moved from kernel 2.6.25.4 to 2.6.26 yesterday and observed that
>> large files sent via Apache2 are partially corrupt.
>>
>> This appears to be linked to sendfile() -- disabling the use of
>> sendfile in the apache config (EnableSendfile Off) allows it to
>> function as normal.
>>
>> My system is a simple Core2Duo running Debian lenny/sid; nothing
>> special, and I have never observed problems like this before.
>>
>> The problem feels certainly related to sendfile() since the data
>> reads correctly from disc in other programs, and via CIFS etc.
>>
>> The corruption happens part-way in to the file... I've no exact
>> figure but it would seem like maybe 32KB -- I'm seeing broken
>> PNGs served from Apache, where the top few dozen lines decode
>> correctly, and the rest is garbage.
>>
>> I've made basically no configuration changes between 2.6.25.4 and
>> 2.6.26 and have explicitly tried both enabling and disabling the
>> new PAT support to no effect.
>>
>> This is completely repeatable and reproducible.
>>
>> Is anyone else seeing this broken behaviour?
>>
>=20
>=20
> What kind of network adapter are you using ? (lspci | grep -i ether)

02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit=20
Ethernet Adapter (rev b0)


> If you disable TCP segmentation offload on this NIC (ethtool -K eth0 =
tso=20
> off) , is this problem still present ?

Wow.  That 'solves' the problem!  Great.

Does this therefore point to an attansic driver issue?


Ian.

