From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net
Date: Thu, 06 Mar 2008 11:40:02 +0300
Message-ID: <47CFADE2.30205@openvz.org>
References: <47CE8FF7.7000701@openvz.org> <m163w03djp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52313 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760962AbYCFIk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 03:40:27 -0500
In-Reply-To: <m163w03djp.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
>> Current /proc/net is done with so called "shadows", but current
>> implementation is broken and has little chances to get fixed.
>>
>> The problem is that dentries subtree of /proc/net directory has
>> fancy revalidation rules to make processes living in different
>> net namespaces see different entries in /proc/net subtree, but
>> currently, tasks see in the /proc/net subdir the contents of any
>> other namespace, depending on who opened the file first.
>>
>> The proposed fix is to turn /proc/net into a symlink, which points
>> to /proc/self/net, which in turn shows what previously was in
>> /proc/net - the network-related info, from the net namespace the
>> appropriate task lives in.
>>
>> # ls -l /proc/net
>> lrwxrwxrwx  1 root root 8 Mar  5 15:17 /proc/net -> self/net
>>
>> In other words - this behaves like /proc/mounts, but unlike
>> "mounts", "net" is not a file, but a directory.
> 
> Overall this looks good, thanks.
> 
> 
> As a follow on patch this should be moved from /proc/<pid>/net
> into /proc/<pid>/task/<tid>/net.

I knew you would request for it :)

> We don't have anything that currently forces network namespaces to be
> the same between different tasks of the same task group (I just
> looked), nor do we have a technical reason to require that.
> 
> So we should fix our infrastructure to include the companion of
> /proc/self, a /proc/current (which points at the current task)
> after which it should be about a two line change to move this
> from the tgid to the task directory.

This is right what I intended to tell you when you would propose
to tune the /proc/net link. I'm glad hearing, that you already
agree with that.

> Eric
> 

