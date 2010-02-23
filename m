From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 12:00:55 -0800
Message-ID: <m1r5obbu2w.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52330 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191Ab0BWUBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 15:01:11 -0500
In-Reply-To: <1266934817.3973.654.camel@bigi> (jamal's message of "Tue\, 23 Feb 2010 09\:20\:17 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> writes:

> Added Daniel to the discussion..
>
> On Tue, 2010-02-23 at 06:07 -0800, Eric W. Biederman wrote:
>> jamal <hadi@cyberus.ca> writes:
>
>> > Does the point after sys_setns(fd) allow me to do io inside
>> > ns <name>? Can i do open() and get a fd from ns <name>?
>> 
>> Yes.  My intention is that current->nsproxy->net_ns be changed.
>> We can already change it in unshare so this is feasible.
>
> I like it if it makes it as easy as it sounds;-> With lxc,
> i essentially have to create a proxy process inside the
> namespace that i use unix domain to open fds inside the ns.
> Do i still need that?

That point of the mount to hold a persistent reference to the
namespace without using a process.

The point of the of the to be written set_ns call is to change
the default network namespace of the process such that all future
open/bind/socket calls happen in the referenced network namespace.

The are a few stray places like sysfs where it is the mount point
not current->nsproxy->net_ns that will determine what we see.

>> > The only problem that i see is events are not as nice. I take it i am 
>> > going to get something like an inotify when a new namespace is created?
>> 
>> Yes.  Inotify would at the very least see that mkdir.  You could also
>> use poll on /proc/mounts to see the set of mounts change.
>
> It is not as nice but livable. I suppose attributes of the specific
> namespace are retrieved somewhere there as well..

Attributes of the specific namespace?

Eric


