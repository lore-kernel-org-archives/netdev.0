From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Thu, 18 Jun 2015 21:08:43 -0400
Message-ID: <20150618210843.4b09c31c@grimm.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150618185051.2b2828c3-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Jun 2015 18:50:51 -0400
Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org> wrote:
 
> The interesting bit here is that the sockets all seem to connect to port
> 55201 on the remote host, if I'm reading these traces correctly. What's
> listening on that port on the server?
> 
> This might give some helpful info:
> 
>     $ rpcinfo -p <NFS servername>

# rpcinfo -p wife
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  34243  status
    100024    1   tcp  34498  status

# rpcinfo -p localhost
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  38332  status
    100024    1   tcp  52684  status
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    2   tcp   2049
    100227    3   tcp   2049
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    2   udp   2049
    100227    3   udp   2049
    100021    1   udp  53218  nlockmgr
    100021    3   udp  53218  nlockmgr
    100021    4   udp  53218  nlockmgr
    100021    1   tcp  49825  nlockmgr
    100021    3   tcp  49825  nlockmgr
    100021    4   tcp  49825  nlockmgr
    100005    1   udp  49166  mountd
    100005    1   tcp  48797  mountd
    100005    2   udp  47856  mountd
    100005    2   tcp  53839  mountd
    100005    3   udp  36090  mountd
    100005    3   tcp  46390  mountd

Note, the box has been rebooted since I posted my last trace.

> 
> Also, what NFS version are you using to mount here? Your fstab entries
> suggest that you're using the default version (for whatever distro this
> is), but have you (e.g.) set up nfsmount.conf to default to v3 on this
> box?
> 

My box is Debian testing (recently updated).

# dpkg -l nfs-*

ii  nfs-common     1:1.2.8-9    amd64        NFS support files common to clien
ii  nfs-kernel-ser 1:1.2.8-9    amd64        support for NFS kernel server


same for both boxes.

nfsmount.conf doesn't exist on either box.

I'm assuming it is using nfs4.

Anything else I can provide?

-- Steve
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
