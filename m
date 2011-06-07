From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Tue, 7 Jun 2011 22:58:34 +0100
Message-ID: <20110607215834.GR11521@ZenIV.linux.org.uk>
References: <20110604001518.GT11521@ZenIV.linux.org.uk>
 <m1k4cy6auf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1k4cy6auf.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2011 at 12:03:52PM -0700, Eric W. Biederman wrote:

> Other pieces of information that should be helpful to know.
> - All sysfs directory entries for a network namespace should be
>   removed from sysfs by the time sysfs_exit_ns is called.

Then why do we need to do _anything_ with ->ns[...]?  Is there any problem
with postponing actual freeing of that sucker until after umount, so that
memory doesn't get reused?  Since everything stale should be gone by the
point when sysfs_exit_ns() would put NULL into ->ns[...], we can as well
keep the old pointer in there - it won't match anything else for as long
as the struct net is not freed...
