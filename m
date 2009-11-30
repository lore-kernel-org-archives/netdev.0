From: David Miller <davem@davemloft.net>
Subject: Re: dmfe/tulip device id overlap
Date: Mon, 30 Nov 2009 12:26:42 -0800 (PST)
Message-ID: <20091130.122642.113956563.davem@davemloft.net>
References: <20091129.003024.245104886.davem@davemloft.net>
	<20091130065512.GA2792@jenkins.domain_not_set.invalid>
	<da824cf30911300914p2d08b87cr4625e9bc30ec7e5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brandon@ifup.org, tobias@ringis.se, kyle@mcmartin.ca,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: grundler@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751712AbZK3U0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:26:37 -0500
In-Reply-To: <da824cf30911300914p2d08b87cr4625e9bc30ec7e5b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@google.com>
Date: Mon, 30 Nov 2009 09:14:01 -0800

> Has anyone posted "lspci -v" output for the "Netra X1 and Sunfire
> V100" motherboards?
> 
> I'm asking because I'm hoping it's possible to disambiguate the add-on
> cards from
> LAN-on-Motherboard cases by looking at subsystem vendor and device IDs as well.

I think more likely OF properties will help here.

Have a look at:

	git://git.kernel.org/pub/scm/linux/kernel/git/davem/prtconfs.git

In particular 'v100' which has a network device OF node with properties:

        Node 0xf007fae8
            .node:  f007fae8
            local-mac-address:  0003ba11.b371
            assigned-addresses:  81006010.00000000.00010000.00000000.00000100.82006014.00000000.00000000.00000000.00002000.82006030.00000000.00040000.00000000.00040000
            version: '1.0'
            compatible:  70636934.3535342c.34333465.00706369.31323868.2c393130.32007063.69313238.322c3931.30320070.6369636c.6173732c.30323030.303000
            device_type: 'network'
            subsystem-id:  0000434e
            subsystem-vendor-id:  00004554
            reg:  00006000.00000000.00000000.00000000.00000000.01006010.00000000.00000000.00000000.00000100.02006014.00000000.00000000.00000000.00000100
            name: 'ethernet'
            devsel-speed:  00000001
            class-code:  00020000
            interrupts:  00000001
            max-latency:  00000028
            min-grant:  00000014
            revision-id:  00000031
            device-id:  00009102
            vendor-id:  00001282

Hmmm, what vendor is '0x4554'? :-)
