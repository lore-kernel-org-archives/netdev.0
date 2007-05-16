From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: 2.6.21-rc7: BUG: sleeping function called from
 invalid context at net/core/sock.c:1523
Date: Wed, 16 May 2007 11:29:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705161124030.25986@twin.jikos.cz>
References: <462D1B09.9050005@goop.org>
	<Pine.LNX.4.64.0704232257090.20657@twin.jikos.cz>
	<Pine.LNX.4.64.0704261625410.20657@twin.jikos.cz>
	<a781481a0705110629n7c7130c1x3a89fa958b271f20@mail.gmail.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>, Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>, bluez-devel@lists.sourceforge.net,
	maxk@qualcomm.com
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a781481a0705110629n7c7130c1x3a89fa958b271f20@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 11 May 2007, Satyam Sharma wrote:

> (later)
> I Googled a bit to see if this problem was faced elsewhere in the kernel
> too. Saw the following commit by Ingo Molnar
> (9883a13c72dbf8c518814b6091019643cdb34429):
> -	lock_sock(sock->sk);
> +	local_bh_disable();
> +	bh_lock_sock_nested(sock->sk);
> 	rc = selinux_netlbl_socket_setsid(sock, sksec->sid);
> -	release_sock(sock->sk);
> +	bh_unlock_sock(sock->sk);
> +	local_bh_enable();
> Is it _really_ *this* simple?

Hi Satyam,

actually this *seems* to be proper solution also for our case, thanks for 
pointing this out. I will think about it once again, do some more tests 
with this locking scheme, and will let you know.

Thanks,

-- 
Jiri Kosina

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
