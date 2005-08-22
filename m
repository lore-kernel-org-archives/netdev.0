From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] Fix socket bitop damage
Date: Mon, 22 Aug 2005 13:14:36 +0200
Message-ID: <20050822111436.GE17371@postel.suug.ch>
References: <20050822110218.GA7514@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@linux-mips.org,
        linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20050822110218.GA7514@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ralf Baechle <20050822110218.GA7514@linux-mips.org> 2005-08-22 12:02
> The socket flag cleanups that went into 2.6.12-rc1 are basically oring
> the flags of an old socket into the socket just being created.
> Unfortunately that one was just initialized by sock_init_data(), so already
> has SOCK_ZAPPED set.  As the result zapped sockets are created and all
> incoming connection will fail due to this bug which again was carefully
> replicated to at least AX.25, NET/ROM or ROSE.

I'm probably to one to blame here but I don't get the point yet.
What I did was to change the bitfield based flags to use sk_flags
like this:

-	sk->sk_zapped   = osk->sk_zapped;
+
+	if (sock_flag(osk, SOCK_ZAPPED))
+		sock_set_flag(sk, SOCK_ZAPPED);
