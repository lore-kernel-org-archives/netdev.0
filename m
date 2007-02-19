From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Converting network devices from class devices causes namespace pollution
Date: Mon, 19 Feb 2007 01:19:59 -0700
Message-ID: <m1y7mu7e4w.fsf@ebiederm.dsl.xmission.com>
References: <m1lkiv8npz.fsf@ebiederm.dsl.xmission.com>
	<20070218194641.GA9929@suse.de>
	<m1bqjr84fe.fsf@ebiederm.dsl.xmission.com>
	<20070219030114.GA13666@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56199 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbXBSIUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 03:20:20 -0500
In-Reply-To: <20070219030114.GA13666@suse.de> (Greg KH's message of "Sun, 18
	Feb 2007 19:01:14 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@suse.de> writes:

> We need our own namespace for these devices, and we have it today
> already.  Look if you enable CONFIG_SYSFS_DEPRECATED, or on a pre-2.6.19
> machine at what shows up in the pci device directories:
> -r--r--r--  1 root root  4096 2007-02-18 13:06 vendor

Interesting.  I hadn't noticed that before.

> So, all we need to do is rename these devices back to the "net:eth0"
> name, and everything will be fine.  I'll work on fixing that tomorrow as
> it will take a bit of hacking on the kobject symlink function and the
> driver core code (but it gets us rid of a symlink in "compatiblity
> mode", which is always a nice win...)

Ok.  I'm groaning a little bit at what a nuisance this is going to be
to get support for multiple network namespaces in there after your fix
goes in, directories can be easier to deal with.  But once you figure this
part out I will figure something out.

For me the nasty case is 1 pci device that has multiple ethernet devices
coming from it (I think IB devices have this property today), each
showing up in a different network namespace, so they might all have
the same name. Ugh.

Eric
