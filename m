From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 20:32:44 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B415CB@avmb3.qlogic.org>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	 <CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
	 <B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
	 <1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>,<1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>,<B5657A6538887040AD3A81F1008BEC63B4159B@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Tom Herbert (Partner - google)" <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:61424 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750939AbaI3Uct convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 16:32:49 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B4159B@avmb3.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> IPv4 header is supposed to have a 0 checksum ;)
>>

>Oops. Sorry, you're right.

>But this is a bit strange.

>I mean, if I go back to the IP-GRE case [with GRE checksum], the IP
>csum negates the rest of the IP header and the GRE csum negates
>everything else [GRE header, inner headers and payload].
>So the mechanism might work as-is, but all the driver has to
>do in order to claim that an IP-gre packet with checksum option is
>CHECKSUM_COMPLETE is to write 0xffffffff on the skb's csum field.

Or looking back on the IPv4/TCP scenario, what exactly is the csum
now protecting?
Assume the HW passes the one's complement sum of the entire data,
IP header and onward to driver, which sets it in SKB->csum and marks
the SKB as CHECKSUM_COMPLETE.
In practice, SKB->csum should now equal to the one's complement of
the TCP pseudo header; But other than the length of data in the TCP
header and payload that pseudo-header doesn't include any
information about the payload itself.
If we're willing to accept the payload [and the correctness of the
header while we're at it] based solely on this, what guarantee do we
have that the TCP checksum is actually correct? 
Seems like the only thing we've guaranteed is that nothing switched in
IP header since packet passed the HW - but we've already got that
covered by the IPv4 layer.

[I assume I'm missing something elementary here. Same as before ;-)]