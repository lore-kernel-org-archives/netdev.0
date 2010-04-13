From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 12:00:24 +0100
Message-ID: <4BC44EC8.1010104@gmail.com>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>		 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>		 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>		 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>		 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>		 <1271085862.16881.38.camel@edumazet-laptop> <4BC3461D.3070002@gmail.com>	 <1271091581.16881.41.camel@edumazet-laptop> <4BC44167.4080807@gmail.com> <1271155766.16881.245.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep12-int.chello.at ([62.179.121.32]:7284 "EHLO
	viefep12-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383Ab0DMLAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:00:31 -0400
In-Reply-To: <1271155766.16881.245.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 13 avril 2010 =C3=A0 11:03 +0100, stephen mulcahy a =C3=A9cr=
it :
>> Eric Dumazet wrote:
>>> OK it seems forcedeth has problem with checksums ?
>>>
>>> Try to change "ethtool -k eth0" settings ?
>>>
>>> ethtool -K eth0 tso off tx off
>> Yes, that makes an unresponsive system responsive again immediately,=
 nice!
>>
>> Should the driver default to disabling this until we problem is corr=
ected?
>>
>> -stephen
>=20
> Both flags need to be disabled, or only one is OK ?

ethtool -K eth0 tx off

fixes the problem (without tso)

but running

ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: off
large-receive-offload: off

seems to indicate that tso is also disabled by this - does that sound=20
correct?

-stephen
