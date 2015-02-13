From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Fri, 13 Feb 2015 17:14:55 +0100
Message-ID: <2370189.uakqRR7OLn@storm>
References: <1719052.SGOfRAJhfQ@storm> <1423654440.27854.83.camel@jtkirshe-mobl> <309B89C4C689E141A5FF6A0C5FB2118B783AC840@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:46465 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbbBMQO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 11:14:59 -0500
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B783AC840@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Aaron,

On Thursday, 12. February 2015 23:28:27 Brown, Aaron F wrote:
> I do not have any real info.  I had been asked to try and reproduce some
> unit hangs (maybe for this) recently and did not succeed in producing
> them on the parts I have.  Reading through the thread I see this is
> showing up in a NAT environment.  The port that is getting the unit hang
> in the NAT system?

yes, the e1000e NIC is serving the NATed Windows client.

The setup was outlined here:

    http://marc.info/?l=linux-netdev&m=142133691713824&w=2

> I will make some attempts at replicating this with the port in a NAT and
> or forwarding role.  Has a bug been opened for this?  Or has information
> for this specific unit hang been entered into one of the other unit hang
> bugs opened against e1000e?

I didn't do anything(tm). This report sounds like the same issue:

    http://ehc.ac/p/e1000/bugs/378/

Oliver Wagner wrote the problem started to appear
after updating from kernel 3.5 to 3.8.0.35 (new frag size code).

I just noticed now he wrote he has two identical boxes:

---------------------------------------------------
- Box with symptoms: Router/Firewall, packet forwarding
  between different VLANs on eth0 and eth1
- Box without symptoms: Fileserver, eth0/eth1 bonded
  (VLANs used, but no forwarding)
---------------------------------------------------

So it looks like it's related to forwarding somehow,
I've made the same experience IIRC.

Cheers,
Thomas
