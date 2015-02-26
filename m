From: Zhaolong Zhang <zhaolong.zhang@windriver.com>
Subject: Re: [PATCH] proc: proc_create() should return true if CONFIG_PROC_FS
 is not configured
Date: Thu, 26 Feb 2015 09:21:28 +0800
Message-ID: <54EE7518.2080005@windriver.com>
References: <1424841259-8470-1-git-send-email-zhangzl2013@126.com> <CAPFHKzcLsL9Sb_ma4_XCm4a0kX_iNcCdFVXf346wtnmOPqWcEg@mail.gmail.com> <15346.1424863160@warthog.procyon.org.uk> <CAPFHKzccoJoM9ZENAT4+zVgbw1xejHEFDrvgz57=Hidk38T+Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zhang Zhaolong <zhangzl2013@126.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	<viro@zeniv.linux.org.uk>
To: Jonathon Reinhart <jonathon.reinhart@gmail.com>,
	David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62173 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbbBZBXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 20:23:15 -0500
In-Reply-To: <CAPFHKzccoJoM9ZENAT4+zVgbw1xejHEFDrvgz57=Hidk38T+Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 05:22 AM, Jonathon Reinhart wrote:
> On Wed, Feb 25, 2015 at 6:19 AM, David Howells<dhowells@redhat.com>  wrote:
>>> >>Does that even compile? proc_create() and proc_create_data() both return
>>> >>"struct proc_dir_entry *". It doesn't make sense for those macros to "return"
>>> >>anything but NULL - certainly not 1.
>>> >>
>>> >>Besides, why shouldn't "if (!proc_create())" behave like proc_create()
>>> >>failed when
>>> >>CONFIG_PROC_FS is not enabled?  You wouldn't want the caller to start trying
>>> >>to use that ((struct proc_dir_entry *)1) would you?
>> >
>> >It's sort of arguable.  If the proc interface is merely informational and
>> >doesn't impact the function of a module to not be present, then, yes, having
>> >proc_create() return some "true" value might make sense.  It's possible to
>> >arrange things so that all the proc-related functions and data get compiled
>> >out in such a situation by not being referenced by anything.
>> >
>> >However, if the proc interface isn't merely functional, then the proc_create()
>> >failure*is*  cause for module loading failure.  But in that case, there should
>> >be a Kconfig dependency on procfs and you should never use the dummy
>> >functions.
> Of the 528 calls to proc_create(_data), only 70 are in an "if (!proc_create())"
> style conditional. Another 188 assign the result to something, presumably a
> "struct proc_dir_entry *, which are going to fail compilation with this patch.

Oh, the usage of the CONFIG_PROC_FS macro should be checked wherever 
proc_create(_data) being called, right?
