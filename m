From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: Problem receiving multicast/promiscuous-mode with kernel.2.6.24
Date: Thu, 7 Feb 2008 16:39:32 +0100
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062F0B@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([88.116.237.238]:11144 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755950AbYBGPjq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 10:39:46 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Visit AVD on prolight+sound in Frankfurt from 12.-15. March 2008 - Hall 8.0, Stand G16
________________________________________________________________________



Hi,

i'm working on a realtime-audio application, which should be capeable to receive RTP packets via multicast addresses.

App did work fine till i switched from 2.6.22 to kernel 2.6.24 (because of hwmon support for VIA EPIA LT15000AG)

With kernel 2.6.22 i had no problems, i'm using almost identical .config
Also tried kernel 2.6.24-rc5, same problem.
Tried it on two different boards (VIA EPIA LT, VIA EPIA 5000, diff. NIC's, cpu's mem, etc ..)

I'm using the same setsockopt with IP_ADD_MEMBERSHIP as before for all interfaces.
But now my app does not receive multicast packets !

Strange thing is, as long as tcpdump is running, the app (and tcpdump) get the multicast packets, but if i stopp tcpdump, my application at the same moment gets no more multicast packets.

I can see with netstat -g the joined MC-address (if app is active)
multicast route is set up properly.

Closer look:
-------------
Right after reboot, receiving of mc-packets worked for just one time.
After one ADD_MEMBERSHIP/DROP_MEMBERSHIP cycle it won't work any longer.

If i deny tcpdump setting promiscous-mode (-p) i get no packets.

Looks like somehow the NIC won't be (re)set to promiscous mode.

My user code:

int join_multicast_group (int fd, const char *mc_address)
{
struct ip_mreqn imr;

log_message(DVA_LOG_INFO,"In join_mc_group: %s\n",mc_address);

if (inet_aton (mc_address, &imr.imr_multiaddr) == 0) {
log_message (DVA_LOG_ERROR, "join_mc:Bad IP address format: %s\n", mc_address);
return -1;
}

imr.imr_address.s_addr = INADDR_ANY;
imr.imr_ifindex = 0;

// Check if already member
if (setsockopt (fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &imr, sizeof (imr)) < 0)
{
if (errno == EADDRINUSE) // Address already joined for IP_ADD_MEMBERSHIP
log_message(DVA_LOG_INFO,"Already joined IP_ADD_MEMBERSHIP for %s.\n", mc_address);
else
{
log_perror (DVA_LOG_ERROR, "getsockopt ip_add_membership");
return -1;
}
}
return 0;
}

and quite the same with DROP_MEMBERSHIP before i close the socket.




Robert Reither
Research & Development
AV Digital Audio- Videotechnik GmbH
Pottendorfer Strasse 25-27/4/1/1
A-1120 Wien/Austria
Commercial Register No.: FN 201615v
Commercial Court: Handelsgericht Wien
VAT-No.: ATU 50461904
Tel.: +43/1/3680368 43
email: robert.reither@av-digital.at
Visit: <http://www.av-digital.at> 


Robert Reither
Research & Development
AV Digital Audio- Videotechnik GmbH
Pottendorfer Strasse 25-27/4/1/1
A-1120 Wien/Austria
Commercial Register No.: FN 201615v
Commercial Court: Handelsgericht Wien
VAT-No.: ATU 50461904
Tel.: +43/1/3680368 43
email: robert.reither@av-digital.at
Visit: <http://www.av-digital.at> 


