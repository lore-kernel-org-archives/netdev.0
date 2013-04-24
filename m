From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Wed, 24 Apr 2013 09:44:33 +0200
Message-ID: <20130424074433.GM18628@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
 <ffc6a5aa-11f5-4e25-b6ac-e1596e8d5437@CMEXHTCAS1.ad.emulex.com>
 <20130409163108.GA6818@eerihug-hybrid.ki.sw.ericsson.se>
 <9982e479-7a8c-4520-999b-9fb59dc62689@CMEXHTCAS2.ad.emulex.com>
 <20130410135337.GD7147@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Perla, Sathya" <Sathya.Perla@Emulex.Com>,
	"Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:60432 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab3DXHof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 03:44:35 -0400
Content-Disposition: inline
In-Reply-To: <20130410135337.GD7147@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got my hands on some new hardware with Intel 82599EB based 10G nics 
(Ixgbe driver)
TIPC GRO works fine with this, the 256b segments sent over a stream connection 
are aggregated together as shown below.

[...]
09:24:36.640506 3c:19:7d:0f:de:44 (oui Unknown) > 3c:19:7d:10:1e:68 (oui Unknown), Unknown Ethertype (0x88ca), length 6950: 
09:24:36.640610 3c:19:7d:0f:de:44 (oui Unknown) > 3c:19:7d:10:1e:68 (oui Unknown), Unknown Ethertype (0x88ca), length 10534: 
09:24:36.640775 3c:19:7d:0f:de:44 (oui Unknown) > 3c:19:7d:10:1e:68 (oui Unknown), Unknown Ethertype (0x88ca), length 18470: 
09:24:36.640863 3c:19:7d:0f:de:44 (oui Unknown) > 3c:19:7d:10:1e:68 (oui Unknown), Unknown Ethertype (0x88ca), length 2598: 
[...]

This confirms that the problem is in be2net driver and/or firmware.

//E
