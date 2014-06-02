From: Stanislav Meduna <stano@meduna.org>
Subject: RSTP with a hardware switch?
Date: Mon, 02 Jun 2014 15:25:11 +0200
Message-ID: <538C7B37.3000909@meduna.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.meduna.org ([92.240.244.38]:59548 "EHLO meduna.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399AbaFBNZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 09:25:20 -0400
Received: from dial-95-105-163-217-orange.orange.sk ([95.105.163.217] helo=[127.0.0.1])
	by meduna.org with esmtpsa (TLS1.0:DHE_RSA_AES_128_CBC_SHA1:16)
	(Exim 4.72)
	(envelope-from <stano@meduna.org>)
	id 1WrSEk-0000hZ-NP
	for netdev@vger.kernel.org; Mon, 02 Jun 2014 15:25:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a 3-port (1 CPU, 2 external) LAN9303 switch with an ability
to set the port status to learning, forwarding etc, pass BPDUs
to CPU even if not forwarding and similar tasks. Using the vlan
tagging feature it is principially possible to expose the ports
as eth0.1, eth0.2 etc, send packets only to specific ports etc.

This is an embedded device where the main task is not the
networking. It "just" needs to have redundant connections
to the same network, as it will be typically wired in a ring
with other such devices and to a RSTP-capable switch at the
end of the ring.

So I need to run a RSTP with this switch and as the CPU power
is limited, I would like to let the hardware do all the
learning and forwarding and only run the RSTP state machine
in software. Unfortunately the existing implementations
such as http://sourceforge.net/projects/mstpd/ expect to
see the bridge and its ports via the bridging infrastructure.

Is there anything in the kernel to help with this task?
If not, what is the suggested way of implementing this?

My present idea is to patch the network driver to use specific
VLANs for the BPDUs and normal traffic and do everything else
in userspace (basically take the daemon and hack other ways
of setting the port status). This however means duplicating
existing interfaces which seems a bit ugly.

Anyone already doing something like this?

If there is a better place to ask this, please suggest it.
Please Cc: when replying.

Thanks
-- 
                                      Stano
