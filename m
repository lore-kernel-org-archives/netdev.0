From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: nfs client hang
Date: Tue, 27 Jul 2010 13:28:44 -0400
Message-ID: <4C4F174C.2000308@oracle.com>
References: <99613C19B13C5D40914FB8930657FA9303365708DE@uk-ex-mbx1.terastack.bluearc.com>	 <4C4E89D4.8040607@bluearc.com>	 <ABFC24E4C13D81489F7F624E14891C8607DDF8D1E4@uk-ex-mbx1.terastack.bluearc.com> <1280233276.2827.175.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Chittenden <andyc-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>,
	"Linux Kernel Mailing List (linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1280233276.2827.175.camel@edumazet-laptop>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add CC: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On 07/27/10 08:21 AM, Eric Dumazet wrote:
> Le mardi 27 juillet 2010 =C3=A0 11:53 +0100, Andy Chittenden a =C3=A9=
crit :
>>>>> IE the client starts a connection and then closes it again withou=
t sending data.
>>>> Once this happens, here's some rpcdebug info for the rpc module us=
ing 2.6.34.1 kernel:
>>>>
>>>> ... lots of the following nfsv3 WRITE requests:
>>>> [ 7670.026741] 57793 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026759] 57794 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026778] 57795 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026797] 57796 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026815] 57797 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026834] 57798 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026853] 57799 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026871] 57800 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026890] 57801 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7670.026909] 57802 0001    -11 ffff88012e32b000   (null)        =
0 ffffffffa03beb10 nfsv3 WRITE a:call_reserveresult q:xprt_backlog
>>>> [ 7680.520042] RPC:       worker connecting xprt ffff88013e62d800 =
via tcp to 10.1.6.102 (port 2049)
>>>> [ 7680.520066] RPC:       ffff88013e62d800 connect status 99 conne=
cted 0 sock state 7
>>>> [ 7680.520074] RPC: 33550 __rpc_wake_up_task (now 4296812426)
>>>> [ 7680.520079] RPC: 33550 disabling timer
>>>> [ 7680.520084] RPC: 33550 removed from queue ffff88013e62db20 "xpr=
t_pending"
>>>> [ 7680.520089] RPC:       __rpc_wake_up_task done
>>>> [ 7680.520094] RPC: 33550 __rpc_execute flags=3D0x1
>>>> [ 7680.520098] RPC: 33550 xprt_connect_status: retrying
>>>> [ 7680.520103] RPC: 33550 call_connect_status (status -11)
>>>> [ 7680.520108] RPC: 33550 call_transmit (status 0)
>>>> [ 7680.520112] RPC: 33550 xprt_prepare_transmit
>>>> [ 7680.520118] RPC: 33550 rpc_xdr_encode (status 0)
>>>> [ 7680.520123] RPC: 33550 marshaling UNIX cred ffff88012e002300
>>>> [ 7680.520130] RPC: 33550 using AUTH_UNIX cred ffff88012e002300 to=
 wrap rpc data
>>>> [ 7680.520136] RPC: 33550 xprt_transmit(32920)
>>>> [ 7680.520145] RPC:       xs_tcp_send_request(32920) =3D -32
>>>> [ 7680.520151] RPC:       xs_tcp_state_change client ffff88013e62d=
800...
>>>> [ 7680.520156] RPC:       state 7 conn 0 dead 0 zapped 1
>>
>>> I changed that debug to output sk_shutdown too. That has a value of=
 2
>>> (IE SEND_SHUTDOWN). Looking at tcp_sendmsg(), I see this:
>>
>>>           err =3D -EPIPE;
>>>           if (sk->sk_err || (sk->sk_shutdown&  SEND_SHUTDOWN))
>>>                   goto out_err;
>>
>>> which correlates with the trace "xs_tcp_send_request(32920) =3D -32=
". So,
>>> this looks like a problem in the sockets/tcp layer. The rpc layer i=
ssues
>>> a shutdown and then reconnects using the same socket. So either
>>> sk_shutdown needs zeroing once the shutdown completes or should be
>>> zeroed on subsequent connect. The latter sounds safer.

>> This patch for 2.6.34.1 fixes the issue:
>>
>> --- /home/company/software/src/linux-2.6.34.1/net/ipv4/tcp_output.c =
    2010-07-27 08:46:46.917000000 +0100
>> +++ net/ipv4/tcp_output.c       2010-07-27 09:19:16.000000000 +0100
>> @@ -2522,6 +2522,13 @@
>>          struct tcp_sock *tp =3D tcp_sk(sk);
>>          __u8 rcv_wscale;
>>
>> +       /* clear down any previous shutdown attempts so that
>> +        * reconnects on a socket that's been shutdown leave the
>> +        * socket in a usable state (otherwise tcp_sendmsg() returns
>> +        * -EPIPE).
>> +        */
>> +       sk->sk_shutdown =3D 0;
>> +
>>          /* We'll fix this up when we get a response from the other =
end.
>>           * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
>>           */
>>
>> As I mentioned in my first message, we first saw this issue in 2.6.3=
2 as supplied by debian (linux-image-2.6.32-5-amd64 Version: 2.6.32-17)=
=2E It looks like the same patch would fix the problem there too.
>>
>
> CC netdev
>
> This reminds me a similar problem we had in the past, fixed with comm=
it
> 1fdf475a (tcp: tcp_disconnect() should clear window_clamp)
>
> But tcp_disconnect() already clears sk->sk_shutdown
>
> If NFS calls tcp_disconnect(), then shutdown(), there is a problem.

If tcp_disconnect() was called at some point, I would expect to see a=20
message from xs_error_report() in the debugging output.  Perhaps=20
tcp_disconnect() is not being invoked at all?

> Maybe xs_tcp_shutdown() should make some sanity tests ?
>
> Following sequence is legal, and your patch might break it.
>
> fd =3D socket(...);
> shutdown(fd, SHUT_WR);
> ...
> connect(fd, ...);


I looked closely at some of Andy's debugging output from the=20
linux-kernel mailing list archive.  I basically agree that the network=20
layer is returning -EPIPE from tcp_sendmsg(), which the RPC client logi=
c=20
does not expect. But it's not clear to me how it gets into this state.

> [ 7728.520042] RPC:       worker connecting xprt ffff88013e62d800 via=
 tcp to 10.1.6.102 (port 2049)
 > [ 7728.520093] RPC:       ffff88013e62d800 connect status 115=20
connected 0 sock state 2

"sock state 2" =3D> sk->sk_state =3D=3D TCP_SYN_SENT

 > [ 7728.520884] RPC:       xs_tcp_state_change client ffff88013e62d80=
0...
 > [ 7728.520889] RPC:       state 1 conn 0 dead 0 zapped 1

"state 1" =3D> sk->sk_state =3D=3D TCP_ESTABLISHED

RPC client wakes up this RPC task now that the connection is establishe=
d.

> [ 7728.520896] RPC: 33550 __rpc_wake_up_task (now 4296824426)
> [ 7728.520900] RPC: 33550 disabling timer
> [ 7728.520906] RPC: 33550 removed from queue ffff88013e62db20 "xprt_p=
ending"
> [ 7728.520912] RPC:       __rpc_wake_up_task done
> [ 7728.520932] RPC: 33550 __rpc_execute flags=3D0x1
> [ 7728.520937] RPC: 33550 xprt_connect_status: retrying
> [ 7728.520942] RPC: 33550 call_connect_status (status -11)

The awoken RPC task's status is -EAGAIN, which prevents a reconnection=20
attempt.

> [ 7728.520947] RPC: 33550 call_transmit (status 0)
> [ 7728.520951] RPC: 33550 xprt_prepare_transmit
> [ 7728.520957] RPC: 33550 rpc_xdr_encode (status 0)
> [ 7728.520962] RPC: 33550 marshaling UNIX cred ffff88012e002300
> [ 7728.520969] RPC: 33550 using AUTH_UNIX cred ffff88012e002300 to wr=
ap rpc data
> [ 7728.520976] RPC: 33550 xprt_transmit(32920)

RPC client encodes the request and attempts to send it.

> [ 7728.520984] RPC:       xs_tcp_send_request(32920) =3D -32

Network layer says -EPIPE, for some reason.  RPC client calls=20
kernel_sock_shutdown(SHUT_WR).

> [ 7728.520997] RPC:       xs_tcp_state_change client ffff88013e62d800=
=2E..
> [ 7728.521007] RPC:       state 4 conn 1 dead 0 zapped 1

"state 4" =3D> sk->sk_state =3D=3D TCP_FIN_WAIT1

The RPC client sets up a linger timeout.

> [ 7728.521013] RPC: 33550 call_status (status -32)
> [ 7728.521018] RPC: 33550 call_bind (status 0)
> [ 7728.521023] RPC: 33550 call_connect xprt ffff88013e62d800 is not c=
onnected
> [ 7728.521028] RPC: 33550 xprt_connect xprt ffff88013e62d800 is not c=
onnected
> [ 7728.521035] RPC: 33550 sleep_on(queue "xprt_pending" time 42968244=
26)
> [ 7728.521040] RPC: 33550 added to queue ffff88013e62db20 "xprt_pendi=
ng"
> [ 7728.521045] RPC: 33550 setting alarm for 60000 ms

RPC client puts this RPC task to sleep.

> [ 7728.521439] RPC:       xs_tcp_state_change client ffff88013e62d800=
=2E..
> [ 7728.521444] RPC:       state 5 conn 0 dead 0 zapped 1

"state 5" =3D> sk->sk_state =3D=3D TCP_FIN_WAIT2

> [ 7728.521602] RPC:       xs_tcp_state_change client ffff88013e62d800=
=2E..
> [ 7728.521608] RPC:       state 7 conn 0 dead 0 zapped 1
> [ 7728.521612] RPC:       disconnected transport ffff88013e62d800

"state 7" =3D> sk->sk_state =3D=3D TCP_CLOSE

The RPC client marks the socket closed. and the linger timeout is=20
cancelled.  At this point, sk_shutdown should be set to zero, correct?=20
I don't see an xs_error_report() call here, which would confirm that th=
e=20
socket took a trip through tcp_disconnect().

> [ 7728.521617] RPC: 33550 __rpc_wake_up_task (now 4296824426)
> [ 7728.521621] RPC: 33550 disabling timer
> [ 7728.521626] RPC: 33550 removed from queue ffff88013e62db20 "xprt_p=
ending"
> [ 7728.521631] RPC:       __rpc_wake_up_task done

RPC client wakes up the RPC task.  Meanwhile...

> [ 7728.521636] RPC:       xs_tcp_state_change client ffff88013e62d800=
=2E..
> [ 7728.521641] RPC:       state 7 conn 0 dead 0 zapped 1
> [ 7728.521645] RPC:       disconnected transport ffff88013e62d800
> [ 7728.521649] RPC:       xs_tcp_data_ready...

=2E.. network layer calls closed socket's data_ready method... while th=
e=20
awoken RPC task gets underway.

> [ 7728.521662] RPC: 33550 __rpc_execute flags=3D0x1
> [ 7728.521666] RPC: 33550 xprt_connect_status: retrying
> [ 7728.521671] RPC: 33550 call_connect_status (status -11)

The awoken RPC task's status is -EAGAIN, which prevents a reconnection=20
attempt, even though there is no established connection.

RPC client barrels on to send the request again.

> [ 7728.521675] RPC: 33550 call_transmit (status 0)
> [ 7728.521679] RPC: 33550 xprt_prepare_transmit
> [ 7728.521683] RPC: 33550 rpc_xdr_encode (status 0)
> [ 7728.521688] RPC: 33550 marshaling UNIX cred ffff88012e002300
> [ 7728.521694] RPC: 33550 using AUTH_UNIX cred ffff88012e002300 to wr=
ap rpc data
> [ 7728.521699] RPC: 33550 xprt_transmit(32920)
> [ 7728.521704] RPC:       xs_tcp_send_request(32920) =3D -32

RPC client attempts to send again, gets -EPIPE, and calls=20
kernel_sock_shutdown(SHUT_WR).  If there is no connection established,=20
the RPC client expects -ENOTCONN, in which case it will attempt to=20
reconnect here.

> [ 7728.521709] RPC:       xs_tcp_state_change client ffff88013e62d800=
=2E..
> [ 7728.521714] RPC:       state 7 conn 0 dead 0 zapped 1
> [ 7728.521718] RPC:       disconnected transport ffff88013e62d800

"state 7" =3D> sk->sk_state =3D=3D TCP_CLOSE

=46ollowing this, the RPC client attempts to retransmit the request=20
repeatedly, but the socket remains in the TCP_CLOSE state.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
