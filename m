From: Minho Ban <mhban-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Fix null pointer dereference in l2cap_chan_send
Date: Tue, 22 May 2012 10:21:02 +0900
Message-ID: <4FBAE9FE.9030807@samsung.com>
References: <4FB9932B.9070101@samsung.com> <20120521161707.GD16942@joana>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20120521161707.GD16942@joana>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/22/2012 01:17 AM, Gustavo Padovan wrote:
> Hi Minho,
> 
> * Minho Ban <mhban-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org> [2012-05-21 09:58:19 +0900]:
> 
>> If l2cap_chan_send is called will null conn it will cause kernel Oops.
>> This patch checks if conn is valid before entering l2cap_chan_send.
> 
> chan->conn should be always valid, and if not we have a bug somewhere else in
> the code and not in l2cap_chan_send(). It could be a locking problem maybe.
> Also check if you can reproduce this with latest bluetooth-next.
> 
> 	Gustavo
> 

Thanks for comment. I'm using bluetooth-next backporting to kernel 3.0
I wonder how do we guarantee chan->conn is valid if other thread release chan->lock
just after exit l2cap_chan_del.
It seem l2cap_chan_del is well protected with various mutex (eg, sk, conn, chan) but
that may not enough to prevent lock waiters from accessing object.

Regards,
Minho Ban
