From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/6] sysfs: Basic support for multiple super blocks
Date: Wed, 31 Mar 2010 07:02:39 -0700
Message-ID: <m1mxxoy4g0.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1269973889-25260-1-git-send-email-ebiederm@xmission.com>
	<4BB2E098.7030202@kernel.org> <m1634d82e0.fsf@fess.ebiederm.org>
	<20100331134757.GA6132@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49475 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048Ab0CaOCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:02:52 -0400
In-Reply-To: <20100331134757.GA6132@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 31 Mar 2010 08\:47\:57 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> Tejun Heo <tj@kernel.org> writes:
>> >> index 30f5a44..030a39d 100644
>> >> --- a/fs/sysfs/sysfs.h
>> >> +++ b/fs/sysfs/sysfs.h
>> >> @@ -114,6 +114,9 @@ struct sysfs_addrm_cxt {
>> >>  /*
>> >>   * mount.c
>> >>   */
>> >> +struct sysfs_super_info {
>> >> +};
>> >> +#define sysfs_info(SB) ((struct sysfs_super_info *)(SB->s_fs_info))
>> >
>> > Another nit picking.  It would be better to wrap SB in the macro
>> > definition.  Also, wouldn't an inline function be better?
>> 
>> Good spotting.  That doesn't bite today but it will certainly bite
>> someday if it isn't fixed.
>> 
>> I wonder how that has slipped through the review all of this time.
>
> (let me demonstrate how: )
>
> WTH are you talking about?  Unless you mean doing (SB) inside
> the definition?
>
> I actually was going to suggest dropping the #define as it obscures
> the code, but I figured it would get more complicated later.

I believe the discuss change was to make the define:
#define sysfs_info(SB) ((struct sysfs_super_info *)((SB)->s_fs_info))

As for dropping the define and using s_fs_info raw.  I rather like
a light weight type safe wrapper.  Maybe I just think s_fs_info
is an ugly name.

In practice I never call sysfs_info() with any expression that has
a side effect, so it doesn't matter.

Eric



