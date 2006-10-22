From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Sat, 21 Oct 2006 17:05:19 -0700
Message-ID: <17722.46527.766894.568446@localhost.localdomain>
References: <200610151820.22867.dpc@asn.pl>
	<17717.40394.531846.695392@localhost.localdomain>
	<200610181115.12471.dpc@asn.pl>
	<17718.63424.509719.492216@localhost.localdomain>
	<eh87aq$71t$1@sea.gmane.org>
	<17720.12801.843076.819750@localhost.localdomain>
	<ehbava$iia$1@sea.gmane.org>
	<17721.32425.591879.97484@localhost.localdomain>
	<ehddcg$2f5$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:51787 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1422785AbWJVAGX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 20:06:23 -0400
To: Pawel Foremski <pjf@asn.pl>
In-Reply-To: <ehddcg$2f5$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pawel Foremski writes:
 > For example because MPPE is optional and some sessions may be encrypted and
 > some not. As I mentioned, we cannot influence the ISP in topic.
 > 
 > More generally, I wanted to present an example of a layer-2 encapsulation
 > that Linux does not know or (as in this case) can't modify the data in it,
 > thus it cannot fix the TCP MSS value.

Given the same problem (securely bridging PPPoE over WiFi) I would
gone with an approach that peeked inside to see if there was MPPE and
in that case done nothing and if there was no MPPE adjusted the MSS of
any TCP traffic and wrapped it in another layer of IPsec+GRE.  The
latter eats up another 40-60 bytes of MTU/MSS but on the positive side
has known security properties and has no reordering issues.  However,
given that the code would be rather ugly (lots of layering violations)
I wouldn't have a high expectation of that code being accepted into a
major Linux tree unless bridged PPPoE over WiFi was something that
lots of users were clamouring for.  Hopefully PPPoE will die out and
make the issue moot.
