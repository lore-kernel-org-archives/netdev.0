From: Toshiharu Harada <haradats@nttdata.co.jp>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Fri, 11 Apr 2008 20:48:30 +0900
Message-ID: <47FF500E.6020503@nttdata.co.jp>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>	 <20080404122408.986477936@I-love.SAKURA.ne.jp>	 <200804071140.59247.paul.moore@hp.com>  <47FC8052.9070409@nttdata.co.jp>	 <1207745357.21223.391.camel@moss-spartans.epoch.ncsc.mil>	 <47FDAC57.9000701@nttdata.co.jp> <1207831882.21223.694.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms1.nttdata.co.jp ([163.135.193.232]:36625 "EHLO
	ms1.nttdata.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759712AbYDKLse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 07:48:34 -0400
In-Reply-To: <1207831882.21223.694.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2008 9:51 PM, Stephen Smalley wrote:
>>> There are two options:
>>> 1) Submit patches to pass down the vfsmounts to the vfs helpers so that
>>> they can be passed to the existing security_inode hooks. -or-
>>> 2) Submit patches to add new security hooks to the callers where the
>>> vfsmount is already available (some have suggested moving the existing
>>> security_inode hooks to the callers, but that would cause problems for
>>> SELinux as I've posted elsewhere, so adding new hooks is preferable, and
>>> then SELinux can just default to the dummy functions for those new
>>> hooks).
>> Thank you for your suggestions. I drew a diagram. Is this correct?
> 
> I think the text above is self-explanatory; I'm not sure what the
> diagram adds.  Also, Matthew Wilcox pointed out a third option that you
> ought to consider, and you can look to the example of audit filesystem
> watches there, which leverages inotify internally.
The diagram was meant to help clarifying things not to add/change
the information. I also like texts but IMO diagrams are useful
for starting arguments over networks.

Yes. Regarding the third option, Tetsuo is preparing to respond
(Matthew, sorry for snail response. it's on the way).

> If that isn't feasible for some reason, then option (2) should be fairly
> straightforward - you just define and insert some new security hooks in
> the callers where the vfsmount is already available.

My diagram worked very well for me. I noticed theoretically
there are four options.

option (1) "pass down the vfsmounts to the vfs helpers"
           (let "vfsmount" bridge namespace and filesystems)
+ LSM needs less changes
- VFS and filesystems need more changes

option (2) "add new security hooks to the callers"
           (adding hooks in namespace)
+ VFS and filesystems need very little changes
- LSM needs to be added new hooks

option (3) "pathname based policy and inode based access control" (by Wilcox)
           (self-explanatory)
+ does not need changes for LSM nor VFS
- can not keep consistency of policy and results

option (4) "introduce completely orthogonal access control besides LSM"
           (like devcgroup, r/o bind mounts (in mm tree))
+ does not need LSM changes
+ pathname based MAC can coexists with label based MAC
- should not ... (the LAST method)


Regarding option 3, Tetsuo will explain difficulties in
another message. TOMOYO Linux project is planning to
make patches of option 2 because it's the most straightforward way
as you suggested. Also we will be carefully watching the
discussion of "vfs: add helpers to check r/o bind mounts".

Regards,
Toshiharu Harada
NTT DATA CORPORATION


