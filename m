From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH] Fix SELinux for removal of i_sock
Date: Mon, 04 Apr 2005 10:13:53 -0400
Message-ID: <1112624033.7629.61.camel@moss-spartans.epoch.ncsc.mil>
References: <1112385997.14481.192.camel@moss-spartans.epoch.ncsc.mil>
	 <20050401123520.7532528b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        matthew@wil.cx
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050401123520.7532528b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-04-01 at 12:35 -0800, David S. Miller wrote:
> On Fri, 01 Apr 2005 15:06:37 -0500
> Stephen Smalley <sds@tycho.nsa.gov> wrote:
> 
> > This patch against -bk eliminates the use of i_sock by SELinux as it
> > appears to have been removed recently, breaking the build of SELinux in
> > -bk.  Simply replacing the i_sock test with an S_ISSOCK test would be
> > unsafe in the SELinux code, as the latter will also return true for the
> > inodes of socket files in the filesystem, not just the actual socket
> > objects IIUC.  Hence this patch reworks the SELinux code to avoid the
> > need to apply such a test in the first place, part of which was
> > obsoleted anyway by earlier changes to SELinux.  Please apply.
> > 
> > Signed-off-by:  Stephen Smalley <sds@tycho.nsa.gov>
> > Signed-off-by:  James Morris <jmorris@redhat.com>
> 
> Applied, thanks Stephen.

So, just for clarification, since a S_ISSOCK test is not necessarily
equivalent to an i_sock test (in the case of inodes of socket files in
the filesystem), was removing i_sock truly the right choice?  It may not
be an issue for typical users of i_sock since you can't open a
descriptor to such a socket file, so any code that was acting on an open
file shouldn't have to deal with this ambiguity, but could possibly lead
to an erroneous use of SOCKET_I on the inode of a socket file in other
code (which is what would have happened in SELinux if we had just
changed the i_sock test to an ISSOCK test).  Thanks, just trying to
avoid confusion in the kernel in the future...
  
-- 
Stephen Smalley <sds@tycho.nsa.gov>
National Security Agency
