From: Mike Auty <mike.auty@gmail.com>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to handle
 vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Wed, 17 Aug 2011 23:48:41 +0100
Message-ID: <4E4C4549.6020802@gmail.com>
References: <bug-41152-10286@https.bugzilla.kernel.org/> <20110816150918.5b2d7067.akpm@linux-foundation.org> <20110817053737.GA1936@minipsycho> <4E4B615F.8060403@gmail.com> <20110817105950.GA4259@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060206040505060804060303"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:60219 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754315Ab1HQWsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 18:48:43 -0400
In-Reply-To: <20110817105950.GA4259@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060206040505060804060303
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 17/08/11 11:59, Jiri Pirko wrote:
> 
> I just obtained very similar card (8086:422b). Going to look at it right
> away.
> 
> One more thing. What do you use to generate vlan0 tagged packets? I'm
> using pktgen with "vlan_id 0". Would you please try that it behaves the
> same for you?
> 	

Sorry, I haven't been using pktgen.  I've got an actual device (a
Samsung android phone) which seems to tag all normal outbound packets
with this type of vlan tag.  I only discovered a month ago that I needed
the 8021q module to be able to talk to it, and then suddenly it stopped
working once I moved to the 3.0 kernel.

I might not have made it clear, but the packets are received (in so much
as the packet is definitely sent, and it's seen by tools such as
wireshark), but no reply is ever sent.  I've attached packet logs from
the 3.0.1 kernel and the 2.6.39.3 kernel.  Oddly the tagging only seems
to be used on the first SYN,ACK packet, but again I don't know enough
about the pipeline or what the Samsung kernel's doing to cause that.

I hope that's of some help?  I may be able to get systemtap support
rolled into my kernel tomorrow at some point, but if not then it will
have to wait until the weekend.  I don't know if that will provide
useful information for debugging this, but I am happy to run whatever
tests I can to figure this out...

Mike  5:)

--------------060206040505060804060303
Content-Type: application/x-extension-pcap;
 name="vlan0-on-kernel-2.6.39.3.pcap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="vlan0-on-kernel-2.6.39.3.pcap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAA4CFMTnAOCwAqAAAAKgAAAP///////1iUa1LY1AgG
AAEIAAYEAAFYlGtS2NTAqLwCAAAAAAAAwKi8BeAhTE5oPgsAKgAAACoAAABYlGtS2NR41vCV
2XEIBgABCAAGBAACeNbwldlxwKi8BViUa1LY1MCovALgIUxOdj4LAEoAAABKAAAAeNbwldlx
WJRrUtjUCABFAAA8qA5AAEAGmVTAqLwCwKi8BdjqABaN46nuAAAAAKACOQj5hwAAAgQFtAQC
CAr//QHgAAAAAAEDAwfgIUxOtnQLAE4AAABOAAAAWJRrUtjUeNbwldlxgQDAAAgARRAAPAAA
QABABkFTwKi8BcCovAIAFtjqUx73EI3jqe+gEhagFhUAAAIEBbQEAggKAjvCy//9AeABAwMB
4CFMTsB0CwBOAAAATgAAAFiUa1LY1HjW8JXZcYEAwAAIAEUQADwAAEAAQAZBU8CovAXAqLwC
ABbY6lMe9xCN46nvoBIWoBYVAAACBAW0BAIICgI7wsv//QHgAQMDAeAhTE70dAsAQgAAAEIA
AAB41vCV2XFYlGtS2NQIAEUAADSoD0AAQAaZW8CovALAqLwF2OoAFo3jqe9THvcRgBAAc/l/
AAABAQgK//0B+wI7wsvgIUxOwusMAFkAAABZAAAAWJRrUtjUeNbwldlxCABFEABLNd9AAEAG
C2XAqLwFwKi8AgAW2OpTHvcRjeOp74AYC1Dw0gAAAQEICgI7wuD//QH7U1NILTIuMC1kcm9w
YmVhcl8wLjUyDQrgIUxOD+wMAEIAAABCAAAAeNbwldlxWJRrUtjUCABFAAA0qBBAAEAGmVrA
qLwCwKi8BdjqABaN46nvUx73KIAQAHP5fwAAAQEICv/9AlsCO8Lg
--------------060206040505060804060303
Content-Type: application/x-extension-pcap;
 name="vlan0-on-kernel-3.0.1.pcap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="vlan0-on-kernel-3.0.1.pcap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAmBhMTjPLBQAqAAAAKgAAAP///////1iUa1LY1AgG
AAEIAAYEAAFYlGtS2NTAqLwCAAAAAAAAwKi8BZgYTE5o5gUAKgAAACoAAABYlGtS2NR41vCV
2XEIBgABCAAGBAACeNbwldlxwKi8BViUa1LY1MCovAKYGExOd+YFAEoAAABKAAAAeNbwldlx
WJRrUtjUCABFAAA8iplAAEAGtsnAqLwCwKi8Bcx+ABbo10w6AAAAAKACOQj5hwAAAgQFtAQC
CAoAAMajAAAAAAEDAwaYGExOag4GAE4AAABOAAAAWJRrUtjUeNbwldlxgQDAAAgARRAAPAAA
QABABkFTwKi8BcCovAIAFsx+pkp8HejXTDugEhagyLkAAAIEBbQEAggKAjSCWwAAxqMBAwMB
mxhMTuvaBQBKAAAASgAAAHjW8JXZcViUa1LY1AgARQAAPIqaQABABrbIwKi8AsCovAXMfgAW
6NdMOgAAAACgAjkI+YcAAAIEBbQEAggKAADSYAAAAAABAwMGmxhMTuIBBwBOAAAATgAAAFiU
a1LY1HjW8JXZcYEAwAAIAEUQADwAAEAAQAZBU8CovAXAqLwCABbMfqZKfB3o10w7oBIWoMZT
AAACBAW0BAIICgI0hMEAAMajAQMDAZwYTE42GQMATgAAAE4AAABYlGtS2NR41vCV2XGBAMAA
CABFEAA8AABAAEAGQVPAqLwFwKi8AgAWzH6mSnwd6NdMO6ASFqDFwAAAAgQFtAQCCAoCNIVU
AADGowEDAwGhGExOnhkGAEoAAABKAAAAeNbwldlxWJRrUtjUCABFAAA8iptAAEAGtsfAqLwC
wKi8Bcx+ABbo10w6AAAAAKACOQj5hwAAAgQFtAQCCAoAAOngAAAAAAEDAwaiGExOKTQJAE4A
AABOAAAAWJRrUtjUeNbwldlxgQDAAAgARRAAPAAAQABABkFTwKi8BcCovAIAFsx+pkp8HejX
TDugEhagwMAAAAIEBbQEAggKAjSKVAAAxqMBAwMB
--------------060206040505060804060303--
