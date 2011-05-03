From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v3 01/10] lsm: add security_socket_closed()
Date: Tue, 03 May 2011 17:41:45 +0200
Message-ID: <87wri73i6e.fsf@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<1304432663-1575-2-git-send-email-sam@synack.fr>
	<201105040029.IGA98088.SHOVQFLOMJtOFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201105040029.IGA98088.SHOVQFLOMJtOFF@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Wed, 4 May 2011 00:29:29 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Samir Bellabes wrote:
>> Allow a module to update security informations when a socket is closed.
> Is security_inode_free() too late for doing it?
>
> static void ccs_inode_free_security(struct inode *inode)
> {
>         if (inode->i_sb && inode->i_sb->s_magic == SOCKFS_MAGIC)
>                 ccs_update_socket_tag(inode, 0);
> }

I don't think it's too late.
But in sock_close() we are sure to deal with a inode which is a socket.

In ccs_inode_free_security(), we need to add small to check if the inode
is a socket or something else.

sam
