From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 2.6.25-rc8-mm1 -- INFO: possible circular locking dependency
	detected (while using iw to debug a wireless issue)
Date: Fri, 04 Apr 2008 17:45:36 +0200
Message-ID: <1207323936.19189.58.camel@johannes.berg>
References: <a44ae5cd0804030741jc9c7aebx21a7635e827b190f@mail.gmail.com>
	 (sfid-20080403_154132_439220_5408BAC7)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-O0Z1pbA2EKqKyXcQDwjG"
Cc: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jouni Malinen <j@w1.fi>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ALSA development <alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
To: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a44ae5cd0804030741jc9c7aebx21a7635e827b190f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20080403_154132_439220_5408BAC7)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-O0Z1pbA2EKqKyXcQDwjG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable


On Thu, 2008-04-03 at 10:41 -0400, Miles Lane wrote:
> After collecting the wireshark log, I found this in my messages log:

Below is a better version of the trace Miles sent me privately, but I
have no idea what would be causing it. I don't think it's related to
wireless.

=EF=BB=BF=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
[ INFO: possible circular locking dependency detected ]
2.6.25-rc8-mm1 #15
-------------------------------------------------------
iw/9417 is trying to acquire lock:
(genl_mutex){--..}, at: [ctrl_dumpfamily+0x37/0xda] ctrl_dumpfamily+0x37/0x=
da

but task is already holding lock:
(nlk->cb_mutex){--..}, at: [netlink_dump+0x39/0x22e] netlink_dump+0x39/0x22=
e

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #1 (nlk->cb_mutex){--..}:
[__lock_acquire+0xa02/0xbaf] __lock_acquire+0xa02/0xbaf
[lock_acquire+0x76/0x9d] lock_acquire+0x76/0x9d
[snd_mixer_oss:mutex_lock_nested+0xd5/0x67b] mutex_lock_nested+0xd5/0x274
[netlink_dump_start+0xbd/0x15a] netlink_dump_start+0xbd/0x15a
[genl_rcv_msg+0x9d/0x13a] genl_rcv_msg+0x9d/0x13a
[netlink_rcv_skb+0x30/0x75] netlink_rcv_skb+0x30/0x75
[genl_rcv+0x1e/0x2e] genl_rcv+0x1e/0x2e
[cfg80211:netlink_unicast+0x1c1/0x1867] netlink_unicast+0x1c1/0x293
[netlink_sendmsg+0x21f/0x22c] netlink_sendmsg+0x21f/0x22c
[sock_sendmsg+0xca/0xe1] sock_sendmsg+0xca/0xe1
[sys_sendmsg+0x14d/0x1a8] sys_sendmsg+0x14d/0x1a8
[sys_socketcall+0x163/0x17e] sys_socketcall+0x163/0x17e
[sysenter_past_esp+0x6d/0xc5] sysenter_past_esp+0x6d/0xc5
       [<ffffffff>] 0xffffffff
-> #0 (genl_mutex){--..}:
[__lock_acquire+0x929/0xbaf] __lock_acquire+0x929/0xbaf
[lock_acquire+0x76/0x9d] lock_acquire+0x76/0x9d
[snd_mixer_oss:mutex_lock_nested+0xd5/0x67b] mutex_lock_nested+0xd5/0x274
[ctrl_dumpfamily+0x37/0xda] ctrl_dumpfamily+0x37/0xda
[netlink_dump+0x51/0x22e] netlink_dump+0x51/0x22e
[netlink_recvmsg+0x156/0x203] netlink_recvmsg+0x156/0x203
[sock_recvmsg+0xd1/0xe9] sock_recvmsg+0xd1/0xe9
[sys_recvmsg+0xf2/0x17f] sys_recvmsg+0xf2/0x17f
[sys_socketcall+0x16f/0x17e] sys_socketcall+0x16f/0x17e
[sysenter_past_esp+0x6d/0xc5] sysenter_past_esp+0x6d/0xc5
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by iw/9417:
 #0: (nlk->cb_mutex){--..}, at: [netlink_dump+0x39/0x22e] netlink_dump+0x39=
/0x22e

stack backtrace:
Pid: 9417, comm: iw Not tainted 2.6.25-rc8-mm1 #15
[print_circular_bug_tail+0x5b/0x66] print_circular_bug_tail+0x5b/0x66
[print_circular_bug_header+0xa5/0xb0] ? print_circular_bug_header+0xa5/0xb0
[__lock_acquire+0x929/0xbaf] __lock_acquire+0x929/0xbaf
[lock_acquire+0x76/0x9d] lock_acquire+0x76/0x9d
[ctrl_dumpfamily+0x37/0xda] ? ctrl_dumpfamily+0x37/0xda
[snd_mixer_oss:mutex_lock_nested+0xd5/0x67b] mutex_lock_nested+0xd5/0x274
[ctrl_dumpfamily+0x37/0xda] ? ctrl_dumpfamily+0x37/0xda
[ctrl_dumpfamily+0x37/0xda] ? ctrl_dumpfamily+0x37/0xda
[ctrl_dumpfamily+0x37/0xda] ctrl_dumpfamily+0x37/0xda
[netlink_dump+0x51/0x22e] netlink_dump+0x51/0x22e
[mac80211:kfree_skb+0x40/0x45] ? kfree_skb+0x40/0x45
[netlink_recvmsg+0x156/0x203] netlink_recvmsg+0x156/0x203
[sock_sendmsg+0xca/0xe1] ? sock_sendmsg+0xca/0xe1
[sock_recvmsg+0xd1/0xe9] sock_recvmsg+0xd1/0xe9
[<c01313d9>] ? autoremove_wake_function+0x0/0x30
[snd_pcm_oss:copy_from_user+0x3b/0x236] ? copy_from_user+0x3b/0x5e
[verify_iovec+0x40/0x70] ? verify_iovec+0x40/0x70
[sys_recvmsg+0xf2/0x17f] sys_recvmsg+0xf2/0x17f
[snd_hda_intel:_spin_unlock_irqrestore+0x56/0x6c] ? _spin_unlock_irqrestore=
+0x56/0x6c
[paravirt_get_lazy_mode+0xe/0x1b] ? paravirt_get_lazy_mode+0xe/0x1b
[crypto_algapi:kunmap_atomic+0x9e/0x2e8e] ? kunmap_atomic+0x9e/0xbb
[handle_mm_fault+0x7aa/0x7bb] ? handle_mm_fault+0x7aa/0x7bb
[sys_socketcall+0x16f/0x17e] sys_socketcall+0x16f/0x17e
[processor:trace_hardirqs_on+0xf0/0x5d38] ? trace_hardirqs_on+0xf0/0x12c
[sysenter_past_esp+0x6d/0xc5] sysenter_past_esp+0x6d/0xc5

--=-O0Z1pbA2EKqKyXcQDwjG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR/ZNH6Vg1VMiehFYAQLhXw/9HGc09vE2SEidrFYGRajzhwxEZoxXbDTi
175k9XXL3mnVnBdlWDZ2Uh4p7fpYhWbrgzvW9KIb5KN+AHL/96/sZn/jyob2T1/i
gSpDjjZrxnMdkQlv7Ym7ZktTjpNAp84N52jbXfY1uaFs4koIjwb6aixlJIjuYmkQ
Dz0r90SXsiRVibYwzco8baaD/8N0LFYhEwVDShRgBRgNS9FMHdUZ4pyCVE4ulBIS
qEbv6R4DorZgyQsdCQiF6cOOYakd7cbT/S0yk82j4LVmiMaaU5jqp3nE3TSheZbw
q20/hNklUTitt6/cU5mpvIYtlc5/YnLjmhxqWDmeY/xAVo2ilvCRm1g6HCepxf14
XVONmCb4sMOPeHkUOefjOlKAfDnD2oIYEWX3mnNJYqkdejU8Y+dcAgjtGdhZPWZ5
Eit+HOSST9B7OOY+S7nVYVhJf62EThsTHBUJCWe3Viue8mZbA1NiOsk+hqQXl02o
BpI1K5H8bBVOFw3At+5mmGX/js72lspx3kv2c+6qLwwYfyqfJCz6m0YmyL9V8x22
Sp+X+Q4givNQMsyvBa/MtatkWojmrE7qV0AuWjG2Rjyvpbp2hISd6T99y+Gh94xi
4tFzTUF/saQB52BrNWkN7wi6tJWTvIF1dCQHTyNmoCrip6LyTL6EycsIqM7GvAWn
rR5IO7Std38=
=fomS
-----END PGP SIGNATURE-----

--=-O0Z1pbA2EKqKyXcQDwjG--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
