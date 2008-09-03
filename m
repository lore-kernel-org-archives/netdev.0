From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mm tree
Date: Wed, 3 Sep 2008 01:44:56 +0100
Message-ID: <20080903004454.GV7908@solarflare.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org> <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com> <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Qicheng Christopher Li <chrisl@vmware.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"arvidjaar@mail.ru" <arvidjaar@mail.ru>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Pratap Subrahmanyam <pratap@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>
To: Zachary Amsden <zach@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:32867 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751575AbYICApK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:45:10 -0400
Content-Disposition: inline
In-Reply-To: <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zachary Amsden wrote:
> On Tue, 2008-09-02 at 14:58 -0700, Brandeburg, Jesse wrote:
[...]
> > VMWare issues really do not apply to the Linux kernel, and unless the
> > architecture of ethtool->ioctl->rtnl->e1000e has changed without me
> > noticing.  In that case every driver that used ethtool would be broken.
> 
> No, any drivers that have a state machine consisting of a base register
> that is used to index which datum is read from device EEPROM by the data
> register would be broken.
> 
> This is not a VMware issue, its a fundamental hardware synchronization
> issue caused by the dependence of data read/write on a device register.
> Does the net layer protect against e1000 issuing simultaneous EEPROM
> read / write?

All ethtool commands are serialised by the RTNL as Jesse said above.

> I have no idea.  It probably should.  Should the driver
> take extra precautions of its own to ensure this on non hot-paths, to
> avoid corrupting EEPROM memory and resulting in a non-functional NIC?
> 
> Absolutely.
> 
> From casual inspection it looks like set_mtu is done under dev_baselock, while ethtool is done under rtnl_lock.
> 
> Setting the MTU internally reads the EEPROM, which could contend with and corrupt and eeprom operations.
 
No, MTU changes are done by another ioctl which takes the RTNL.  It's
not hard to find this stuff in net/core/dev.c.

Please do VMware driver developers a favour and pay a little more
attention to such subtleties.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
