From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] new module infrastructure for net_proto_family
Date: Sat, 19 Apr 2003 15:17:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030419.151706.86912986.davem@redhat.com>
References: <20030419161457.GA6164@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030419161457.GA6164@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Sat, 19 Apr 2003 13:14:57 -0300

Have a look at this:

   diff -Nru a/net/socket.c b/net/socket.c
   --- a/net/socket.c	Sat Apr 19 13:10:22 2003
   +++ b/net/socket.c	Sat Apr 19 13:10:22 2003
   @@ -506,8 +506,10 @@
     
    void sock_release(struct socket *sock)
    {
   -	if (sock->ops) 
   +	if (sock->ops) {
    		sock->ops->release(sock);
   +		module_put(net_families[sock->ops->family]->owner);
   +	}
    

Maybe you want to cache sock->ops->family before calling
sock->ops->release, maybe nobody does it but it could be
legal to NULL sock->ops during sock->ops->release()

If anything this code should NULL'ify it because any reference to
sock->ops after the release and module_put() is a BUG() that should be
trapped.
