From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: git repository for net drivers available
Date: Fri, 13 May 2005 11:29:30 -0400
Message-ID: <4284C7DA.1020707@pobox.com>
References: <42841A3F.7020909@pobox.com> <4284C54E.3060907@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <4284C54E.3060907@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> Jeff Garzik wrote:
> 
> 
>>This includes the wireless-2.6 repository.
>>
>>rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>>
>>The main branch is fairly irrelevant, as you must choose the branch
>>you wish:
>>
>>
>>>[jgarzik@pretzel netdev-2.6]$ ls .git/branches/
>>>8139cp         e1000        ixgb     r8169            skge          
>>>we18
>>>8139too-iomap  forcedeth    janitor  register-netdev  smc91x        
>>>wifi
>>>amd8111        ieee80211    orinoco  remove-drivers   smc91x-eeprom
>>>e100           iff-running  ppp      sis900           starfire
>>
> Ok, I'll bite.  Hopefully I'm not the only one tripping on shoe laces...
> 
> Here is what I did -- what am I doing wrong?
> 
> Following is using cogito 0.10:
> 
> REPO=rsync://rsync.kernel.org/pubs/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> cg-clone ${REPO}
> .... get coffee, etc. ... come back and I have a netdev-2.6 tree ...
> cg-branch-add wifi ${REPO}#wifi
> cg-update wifi
> .... connects and attempts to download but fails out with:
> 
> ----------------
> receiving file list ... done
> client: nothing to do: perhaps you need to specify some filenames or the
> --recursive option?
> 
> rsync: link_stat
> "/scm/linux/kernel/git/jgarzik/netdev-2.6.git/heads/wifi" (in pub)
> failed: No such file or directory (2)

Looks like cogito is using $repo/heads/$branch, whereas my git repo is 
using $repo/branches/$branch.

You can achieve what's necessary with

> rsync --verbose --delete --stats --progress \
> -a rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git/ .git

and then

> ( cd .git ; rm -f HEAD ; ln -s branches/wifi HEAD )

and then

> git-read-tree $(cat .git/HEAD) && git-checkout-cache -q -f -a && git-update-cache --refresh



For what it's worth, this is only netdev-2.6 as it appeared in 
BitKeeper.  I am only now merging all the emailed patches since BK devel 
stopped into git, which includes the ipw code you submitted.

	Jeff
