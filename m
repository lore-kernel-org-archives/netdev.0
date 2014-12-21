From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: SRIOV fdb and modes WAS(Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 09:46:04 -0500
Message-ID: <5496DD2C.6090103@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:52340 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbaLUOqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 09:46:07 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so3057910ier.6
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 06:46:06 -0800 (PST)
In-Reply-To: <54905F67.2090509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


John,

On CPU port: Yes, a VF with PCIE params is considered a "CPU port".
This is fine for SRIOV because it ties VF to a "CPU port". Other
ASIC models have an explicit single "CPU port" (I would say the tiny
openwrt types or larger broadcom switches). In such a case you program
separately the cpu MAC addresses and then you teach some table to
send to the CPU port. It doesnt matter whether it is L2 or L3. As
an example you can point a L3 NH to cpu port with a CPU port MAC address
so things dont show up as skb HOST tagged on the stack.
On Linux infact without the concept of an fdb - this is also true.
i.e not all NICs have an fdb. Macvlan was initially introduced (Patrick
McHardy iirc) to expose the multiple MAC address a standard NIC has.
Conflating this with having an fdb is where the water got mudied in my
opinion. I should be able to dump these MAC addresses without expecting
that i need to talk to an underlying hardware dumper (hence the default
dumper). Unless it is true today that _all_ NICs with multiple MACs have
an embedded fdb.
To summarize: I dont think we disagree much - i just wanted to emphasize
the concept of "cpu port" being important.

Other thing you brought up was the concept of uplink/downlink relay
ports.  The more i think about it, the more i am reaching a conclusion
that they are *not* anything speacial.
Essentially, in one case you have the port column pointing to the VF
after you populate the underlying fdb. By default it doesnt seem these
SRIOV switches cant learn. We have knobs for that and capability is
exposable to point to the fact
And it seems to me that VEPA is just a mode where flooding control
points out one port connected externally.
We already have knobs per port flood and learning controls.

cheers,
jamal
