From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: wither bounds checking for networking sysctls
Date: Sun, 09 Sep 2007 09:26:51 -0600
Message-ID: <m1y7ffsvus.fsf@ebiederm.dsl.xmission.com>
References: <46D76A3D.9090207@hp.com> <20070830205939.2f85a567@localhost>
	<46D84C8D.4070009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:43772 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757454AbXIIP1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 11:27:18 -0400
In-Reply-To: <46D84C8D.4070009@hp.com> (Rick Jones's message of "Fri, 31 Aug
	2007 10:14:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:

> Stephen Hemminger wrote:
>> On Thu, 30 Aug 2007 18:09:17 -0700
>> Rick Jones <rick.jones2@hp.com> wrote:
>>
>>
>>> While messing about with "sysctl_tcp_rto_min" I went back and forth a bit as
>>> to whether there should have been bounds checking (as did some of the folks
>>> who did some internal review for me).  That leads to the question - is it
>>> considered worthwhile to add a bit more bounds checking to sundry networking
>>> sysctls?
>>>
>>>rick jones
>>
>>
>> IMHO As long as the any value from sysctl doesn't crash kernel, we
>> should let it go. Enforcing RFC policy or inter-dependencies seems
>> likes a useless exercise.
>
> I was thinking more along the lines of more fundamental things - like precluding
> negative values when something is clearly a positive.

The sysctl infrastructure has some fairly simple support for
doing min/max type things.  So if it makes sense it isn't hard to
make proc_dointvec_minmax the method and then set extra1 to point to
the min and extra2 to be the max. 

Eric
