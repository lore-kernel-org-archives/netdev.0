From: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: shutdown(3) and bluetooth.
Date: Tue, 12 Nov 2013 17:48:19 -0500
Message-ID: <20131112224819.GE9057@redhat.com>
References: <20131112211125.GA2912@redhat.com>
 <DF4C2B40-BD87-4E88-911D-E3E5F488CAE4@holtmann.org>
 <20131112221038.GA6689@redhat.com>
 <FC5CE013-B077-4EA5-81C1-A7D8B4A5EF85@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org development"
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <FC5CE013-B077-4EA5-81C1-A7D8B4A5EF85-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2013 at 07:32:09AM +0900, Marcel Holtmann wrote:
 
 > > Here's the info I found in the logs, it looks like this was the only bluetooth socket.
 > > 
 > > fd[195] = domain:31 (PF_BLUETOOTH) type:0x5 protocol:2
 > > Setsockopt(1 d 2134000 8) on fd 195
 > 
 > this is a bit confusing. Protocol 2 is actually SCO, but the stack trace shows RFCOMM.
 
Sorry, mixed up two separate runs. In the log above, the stack trace is actually..

[<ffffffffa0492dca>] bt_sock_wait_state+0xda/0x240 [bluetooth]
[<ffffffffa04c86d8>] sco_sock_release+0xb8/0xf0 [bluetooth]
[<ffffffff815cb1ff>] sock_release+0x1f/0x90
[<ffffffff815cb282>] sock_close+0x12/0x20


 > > ./trinity -P PF_BLUETOOTH -l off -c setsockopt
 > > 
 > > let it run a few seconds, and then ctrl-c.  The main process will never exit.
 > > 
 > > 5814 pts/6    Ss     0:00              |       \_ bash
 > > 5876 pts/6    S+     0:00              |       |   \_ ./trinity -P PF_BLUETOOTH -l off -c setsockopt
 > > 5877 pts/6    Z+     0:00              |       |       \_ [trinity] <defunct>
 > > 5878 pts/6    S+     0:01              |       |       \_ [trinity-main]
 > > 
 > > $ sudo cat /proc/5878/stack
 > > [<ffffffffa04397a2>] bt_sock_wait_state+0xc2/0x190 [bluetooth]
 > > [<ffffffffa0847a75>] rfcomm_sock_shutdown+0x85/0xb0 [rfcomm]
 > > [<ffffffffa0847ad9>] rfcomm_sock_release+0x39/0xb0 [rfcomm]

So it seems it affects both SCO and RFCOMM.

 > What kernel did you run this against? It is a shot in the dark, but can you try linux-next quickly.
 > There was a socket related fix for the socket options where we confused RFCOMM vs L2CAP struct sock.

first noticed it on Linus' latest HEAD, and then reproduced it on 3.11.6
I'll look at linux-next tomorrow.

thanks,

	Dave
