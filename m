From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] sunrpc: make closing of old temporary sockets
	work	(was: problems with lockd in 2.6.22.6)
Date: Wed, 12 Sep 2007 14:42:22 -0400
Message-ID: <20070912184222.GG4274@fieldses.org>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de>
	<18151.62510.891210.485277@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <18151.62510.891210.485277@notabene.brown>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Sep 12, 2007 at 04:14:06PM +0200, Neil Brown wrote:
> So it is in 2.6.21 and later and should probably go to .stable for .21
> and .22.
> 
> Bruce:  for you :-)

OK, thanks!  But, (as is alas often the case) I'm still confused:

>  		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
>  			continue;
> -		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
> +		if (atomic_read(&svsk->sk_inuse) > 1
> +		    || test_bit(SK_BUSY, &svsk->sk_flags))
>  			continue;
>  		atomic_inc(&svsk->sk_inuse);
>  		list_move(le, &to_be_aged);

What is it that ensures svsk->sk_inuse isn't incremented or SK_BUSY set
after that test?  Not all the code that does either of those is under
the same serv->sv_lock lock that this code is.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
