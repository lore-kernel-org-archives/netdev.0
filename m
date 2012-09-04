From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Providing protocol type via system.sockprotoname
 xattr of /proc/PID/fd entries
Date: Tue, 04 Sep 2012 15:52:56 -0400 (EDT)
Message-ID: <20120904.155256.1287732878726830374.davem@davemloft.net>
References: <1346273069-5390-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yamato@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346273069-5390-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masatake YAMATO <yamato@redhat.com>
Date: Thu, 30 Aug 2012 05:44:29 +0900

> lsof reports some of socket descriptors as "can't identify protocol" like:
> 
>     [yamato@localhost]/tmp% sudo lsof | grep dbus | grep iden
>     dbus-daem   652          dbus    6u     sock ... 17812 can't identify protocol
>     dbus-daem   652          dbus   34u     sock ... 24689 can't identify protocol
>     dbus-daem   652          dbus   42u     sock ... 24739 can't identify protocol
>     dbus-daem   652          dbus   48u     sock ... 22329 can't identify protocol
>     ...
> 
> lsof cannot resolve the protocol used in a socket because procfs
> doesn't provide the map between inode number on sockfs and protocol
> type of the socket.
> 
> For improving the situation this patch adds an extended attribute named
> 'system.sockprotoname' in which the protocol name for
> /proc/PID/fd/SOCKET is stored. So lsof can know the protocol for a
> given /proc/PID/fd/SOCKET with getxattr system call.
> 
> A few weeks ago I submitted a patch for the same purpose. The patch
> was introduced /proc/net/sockfs which enumerates inodes and protocols
> of all sockets alive on a system. However, it was rejected because (1)
> a global lock was needed, and (2) the layout of struct socket was
> changed with the patch.
> 
> This patch doesn't use any global lock; and doesn't change the layout
> of any structs.
> 
> In this patch, a protocol name is stored to dentry->d_name of sockfs
> when new socket is associated with a file descriptor. Before this
> patch dentry->d_name was not used; it was just filled with empty
> string. lsof may use an extended attribute named
> 'system.sockprotoname' to retrieve the value of dentry->d_name.
> 
> It is nice if we can see the protocol name with ls -l
> /proc/PID/fd. However, "socket:[#INODE]", the name format returned
> from sockfs_dname() was already defined. To keep the compatibility
> between kernel and user land, the extended attribute is used to
> prepare the value of dentry->d_name.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

This looks a lot more reasonable than your previous attempt.

Applied to net-next, thanks a lot.
