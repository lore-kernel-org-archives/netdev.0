From: John Rose <johnrose@austin.ibm.com>
Subject: Re: [PATCH 2.6.21-rc1] ehea: dynamic add / remove port
Date: Thu, 15 Feb 2007 11:04:58 -0600
Message-ID: <1171559098.20758.70.camel@sinatra.austin.ibm.com>
References: <200702141536.28665.ossthema@de.ibm.com>
	 <1171491906.30473.3.camel@sinatra.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, stefan.roscher@de.ibm.com,
	netdev <netdev@vger.kernel.org>,
	Nathan Fontenot <nfont@austin.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:44493 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030248AbXBORIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 12:08:23 -0500
In-Reply-To: <1171491906.30473.3.camel@sinatra.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Second, the probe and remove functions do not communicate whether an add
> or remove was successful.  Combine this with the lack of port
> information in the adapter sysfs directory, and the userspace tool has
> no way of verifying a dynamic add/remove.

One way to communicate a return code is by making the sysfs interface
file read/write, and having the read callback give a return code.  For
an example of this, you can look at drivers/pci/rpadlpar_sysfs.c and
rpadlpar_core.c.

It would still be nice to have some way from the adapter sysfs directory
to list/examine logical ports.  Symlinks would work, but it would be
even nicer to have a new kobject per port with attribute files for
logical id, state, etc.

