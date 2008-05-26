From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Cache coherency, transactions, parallels.
Date: Mon, 26 May 2008 11:44:24 +0400
Message-ID: <20080526074424.GA555@2ka.mipt.ru>
References: <20080525134055.GA30630@2ka.mipt.ru> <483A0F3B.9060709@garzik.org> <20080526062204.GA16366@2ka.mipt.ru> <483A59D7.7020306@garzik.org> <20080526070708.GB16366@2ka.mipt.ru> <483A667F.7070707@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39820 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751851AbYEZHo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 03:44:27 -0400
Content-Disposition: inline
In-Reply-To: <483A667F.7070707@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 26, 2008 at 03:27:59AM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> git-update-server-info needs to be run on the server, not the client.
> 
> You can automate this by running this on the server:
> 
> 	chmod +x .git/hooks/post-update
> 
> so that git-update-server-info always runs on the server, after each push.
> 
> See git-update-server-info(1) for more info.

Hmm... Nothing can be run on server, since git does not believe it is in
git repo:
$ strace git-update-server-info
execve("/usr/bin/git-update-server-info", ["git-update-server-info"], [/* 20 vars */]) = 0

... ommitting mapping and shared lib loading ...

getcwd("/home/s0mbre/public_html/archive/pohmelfs/pohmelfs.git", 4097) = 55
access(".git/refs/", X_OK)              = -1 ENOENT (No such file or directory)
chdir("..")                             = 0
access(".git/refs/", X_OK)              = -1 ENOENT (No such file or directory)
chdir("..")                             = 0
access(".git/refs/", X_OK)              = -1 ENOENT (No such file or directory)
chdir("..")                             = 0
access(".git/refs/", X_OK)              = -1 ENOENT (No such file or directory)
chdir("..")                             = 0
access(".git/refs/", X_OK)              = -1 ENOENT (No such file or directory)
chdir("..")                             = 0
access(".git/refs/", X_OK)              = -1 ENOENT (No such file or directory)
chdir("..")                             = 0
access(".git/refs/", X_OK)              = -1 ENOENT (No such file or directory)
chdir("..")                             = 0
write(2, "fatal: ", 7fatal: )                  = 7
write(2, "Not a git repository", 20Not a git repository)    = 20
write(2, "\n", 1

Obviously there is no .git dir, since we are in it:

pohmelfs.git$ ls -l
total 14
-rw-r--r--  1 s0mbre s0mbre   23 May 13 21:33 HEAD
drwxr-xr-x  2 s0mbre s0mbre   48 May 13 21:33 branches
-rw-r--r--  1 s0mbre s0mbre   66 May 13 21:31 config
-rw-r--r--  1 s0mbre s0mbre   58 May 13 21:33 description
drwxr-xr-x  2 s0mbre s0mbre  328 May 13 21:33 hooks
drwxr-xr-x  2 s0mbre s0mbre   96 May 13 21:33 info
drwxr-xr-x 67 s0mbre s0mbre 1608 May 26 10:20 objects
drwxr-xr-x  5 s0mbre s0mbre  120 May 26 10:20 refs

And it can not be accessed from higher layer, since its name is not
'.git', but 'pohmelfs.git'.

pohmelfs.git$ ls -l ../
total 440
-rw-r--r-- 1 s0mbre s0mbre  90994 Apr 25 18:37 pohmelfs.1
-rw-r--r-- 1 s0mbre s0mbre  90998 May 12 13:28 pohmelfs.1.fixed
-rw-r--r-- 1 s0mbre s0mbre 119384 May 13 21:35 pohmelfs.2
-rw-r--r-- 1 s0mbre s0mbre 136685 May 25 17:20 pohmelfs.3
drwxr-xr-x 7 s0mbre s0mbre    248 May 13 21:33 pohmelfs.git
drwxr-xr-x 3 s0mbre s0mbre    256 May 26 00:19 server

I've updated by hand info/refs, which pointed to the previous revision,
but really thought it was mande somewhat automatically? It was created
when I made a exportable git tree, when I did git-update-server-info.
Git is a magic yet to resolve :)

-- 
	Evgeniy Polyakov
