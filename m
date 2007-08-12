From: david@lang.hm
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it,
 anyways? [compare with e.g. NBD + MD raid])
Date: Sun, 12 Aug 2007 09:39:54 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm>
References: <200708121335.17267.a1426z@gawab.com>
 <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Al Boldi <a1426z@gawab.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-raid@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 12 Aug 2007, Jan Engelhardt wrote:

> On Aug 12 2007 13:35, Al Boldi wrote:
>> Lars Ellenberg wrote:
>>> meanwhile, please, anyone interessted,
>>> the drbd paper for LinuxConf Eu 2007 is finalized.
>>> http://www.drbd.org/fileadmin/drbd/publications/
>>> drbd8.linux-conf.eu.2007.pdf
>>>
>>> but it does give a good overview about what DRBD actually is,
>>> what exact problems it tries to solve,
>>> and what developments to expect in the near future.
>>>
>>> so you can make up your mind about
>>>  "Do we need it?", and
>>>  "Why DRBD? Why not NBD + MD-RAID?"
>
> I may have made a mistake when asking for how it compares to NBD+MD.
> Let me retry: what's the functional difference between
> GFS2 on a DRBD .vs. GFS2 on a DAS SAN?

GFS is a distributed filesystem, DRDB is a replicated block device. you 
wouldn't do GFS on top of DRDB, you would do ext2/3, XFS, etc

DRDB is much closer to the NBD+MD option.

now, I am not an expert on either option, but three are a couple things 
that I would question about the DRDB+MD option

1. when the remote machine is down, how does MD deal with it for reads and 
writes?

2. MD over local drive will alternate reads between mirrors (or so I've 
been told), doing so over the network is wrong.

3. when writing, will MD wait for the network I/O to get the data saved on 
the backup before returning from the syscall? or can it sync the data out 
lazily

>> Now, shared remote block access should theoretically be handled, as does
>> DRBD, by a block layer driver, but realistically it may be more appropriate
>> to let it be handled by the combining end user, like OCFS or GFS.

there are times when you want to replicate at the block layer, and there 
are times when you want to have a filesystem do the work. don't force a 
filesystem on use-cases where a block device is the right answer.

David Lang
