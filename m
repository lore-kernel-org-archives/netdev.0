From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Converting network devices from class devices causes namespace pollution
Date: Sun, 18 Feb 2007 15:52:05 -0700
Message-ID: <m1bqjr84fe.fsf@ebiederm.dsl.xmission.com>
References: <m1lkiv8npz.fsf@ebiederm.dsl.xmission.com>
	<20070218194641.GA9929@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40603 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbXBRWwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Feb 2007 17:52:33 -0500
In-Reply-To: <20070218194641.GA9929@suse.de> (Greg KH's message of "Sun, 18
	Feb 2007 11:46:41 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@suse.de> writes:

> On Sun, Feb 18, 2007 at 08:55:20AM -0700, Eric W. Biederman wrote:
>> User space is allowed to rename network devices to anything any name
>> not currently taken by another network device.
>> 
>> However when I now do something like:
>> 
>> ip link set eth0 name irq
>> 
>> The rename half happens (because it is legal), but sysfs can't support
>> it because of the ridiculous directory eth0 is in.  After that
>> point things go hideously wrong.
>
> What goes wrong?  What is not renamed properly?

It gets half renamed. 

> Oh, you can't rename it to something like "irq".  Well that's pretty
> foolish on your behalf :)

No it is pretty foolish on your behalf to add this extra restriction.
Currently this is a worse set of restrictions than DOS had with
it's magic character devices.

>> The current situation is hideous namespace pollution, and breaks user
>> space, and is only likely only a matter of time before we have a
>> reasonable instead of an strained conflict of names.
>
> Do we really have a problem here?

Yes.

>> Is there any simple fix or do we need to revert the change away
>> from class_device?
>
> We need the class_device change to get suspend/resume working properly,
> and to make a lot of other things better (unified device tree, smaller
> kernel images, etc.)

Which is why I'm asking for a fix, that we can merge.

> But my main point remains, is this really a problem?  Do systems really
> name their network devices with names that stop working with this change
> today?  Distros use the mac address these days to name network devices
> in a unique way, and that namespace does not conflict with the pci
> attributes.

- The error handling is not correct so if someone tries it you loose
  your network device.  Bad BUG.

- This is gratuitous ABI breakage.  Give me the 2 years notice that is
  implied in Documentation/ABI/README and you may have a case.

- The namespace conflicts because the pci attributes are legal network
  device names, and there is nothing that causes me to expect that
  we won't add a pci attribute that will not be an interesting network
  device name.

Fixing this theoretically isn't very hard all you have do to is insert
an extra subdirectory and remove any possible conflict.

Eric
