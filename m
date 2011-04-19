From: Amit Virdi <amit.virdi@st.com>
Subject: Re: Testing IRDA device driver
Date: Tue, 19 Apr 2011 15:44:30 +0530
Message-ID: <4DAD6086.6050504@st.com>
References: <4DA54554.7020500@st.com> <4DA830EF.701@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amit Virdi <amit.virdi@st.com>, <netdev@vger.kernel.org>
To: <samuel@sortiz.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:32885 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754477Ab1DSKOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 06:14:49 -0400
In-Reply-To: <4DA830EF.701@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

I have been trying to transfer a file from one system to another using 
IrCOMM layer on IrDA. We have a DICE's Fast IrDA Controller on our board 
and I've written driver for the same. I need your help in 
finding/resolving the problem, please.

In my setup, I'm using two identical boards having the IrDA IP logic. 
Once the board is up, I'm executing two commands:
1. ifconfig irda0 up
2. echo 1 > /proc/sys/net/irda/discovery

Both the IrDA devices discover each other successfully. If I run 
irattach, I can see SNRM command being sent and its response being 
received on one board. Then some more messages are exchanged- i:cmd, 
i:rsp, rr:cmd etc. I could see QOS parameters being exchanged. However, 
after this rr:cmd and rr:rsp messages are exchanged for sometime and 
then I get "IrLAP, no activity on link!" messages. No more messages are 
exchanged thereafter.I took the irdadump logs for both the transmitter 
and receiver. All the messages sent by the transmitter are received 
successfully.

Meanwhile, when the rr:cmd rr:rsp messages are being exchanged, I tried 
using ircp to transfer/receive file, but received an error message 
"Connecting...failed". Could you please help me? I'm really bogged down 
by this problem. I've been trying hard for the past couple of weeks. I 
shall be very much thankful to you.

Best Regards
Amit Virdi

On 4/15/2011 5:20 PM, Amit Virdi wrote:
> Hi All/Samuel,
>
> I need your help in transferring file through IrCOMM layer.
>
> I'm facing a strange problem. I'm using same kernel image on two 
> similar boards. When I run irattach /dev/ircomm0 on one board, the 
> DISCOVERY protocol is initiated and the IrDA devices on both the 
> boards detect each other. When irattach is run on board 2 also, SNRM 
> command is sent by board 2 and UA response is received by it. After 
> few more commands, "sirdev_receive  too early" message is displayed 
> multiple times and then "IrLAP, no activity on the link" message is 
> received. The subsequent DISCOVERY REQUEST/RESPONSE does not have the 
> hint field as c404 but 4400. If I run ircp -r on one board or ircp 
> <filename>, I get "Connecting... failed" message.
>
> Is anyone having a clue what might be the problem?Here's the detailed 
> description of the scenario:
> 1. When the boards are booted up, I run ifconfig irda0 up on both the 
> boards. The port is up, no IrDA message is exchanged.
> 2. I run "irattach /dev/ircomm0 -s" on board 1. IrDA discovery 
> protocol is initiated, XID command is sent and XID response is 
> received. irdadump utility shows the messages exchanged.
> =============
> root@driver_s320:~# irattach /dev/ircomm0 -s &
> [2] 1456
> root@driver_s320:~# 00:02:08.167760 (37538.46 ms) xid:cmd f41be1cd > 
> ffffffff S=6 s=0 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 00 00
> 00:02:08.261248 (0093.49 ms) xid:cmd f41be1cd > ffffffff S=6 s=1 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 01 00
> 00:02:08.361205 (0099.96 ms) xid:cmd f41be1cd > ffffffff S=6 s=2 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 02 00
> 00:02:08.362522 (0001.32 ms) xid:rsp f41be1cd < 0c4619da S=6 s=2 Linux 
> hint=4400 [ Computer LAN Access ] (21)
>         fe bf 01 da 19 46 0c cd e1 1b f4 01 02 00 44 00
>         4c 69 6e 75 78
> 00:02:08.461210 (0098.69 ms) xid:cmd f41be1cd > ffffffff S=6 s=3 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 03 00
> 00:02:08.561216 (0100.01 ms) xid:cmd f41be1cd > ffffffff S=6 s=4 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 04 00
> 00:02:08.661216 (0100.00 ms) xid:cmd f41be1cd > ffffffff S=6 s=5 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 05 00
> 00:02:08.761269 (0100.05 ms) xid:cmd f41be1cd > ffffffff S=6 s=* Linux 
> hint=c404 [ Computer LAN Access IrCOMM ] (22)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 ff 00 c4 04
>         00 4c 69 6e 75 78
> 00:02:12.351472 (3590.20 ms) xid:cmd f168e953 > ffffffff S=6 s=0 (14)
>         ff 3f 01 53 e9 68 f1 ff ff ff ff 01 00 00
> 00:02:12.351818 (0000.35 ms) xid:cmd f41be1cd > ffffffff S=6 s=0 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 00 00
> 00:02:12.451344 (0099.53 ms) xid:cmd f41be1cd > ffffffff S=6 s=1 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 01 00
> 00:02:12.551376 (0100.03 ms) xid:cmd f41be1cd > ffffffff S=6 s=2 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 02 00
> 00:02:12.651354 (0099.98 ms) xid:cmd f41be1cd > ffffffff S=6 s=3 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 03 00
> 00:02:12.751354 (0100.00 ms) xid:cmd f41be1cd > ffffffff S=6 s=4 (14)
>         ff 3f 01 cd e1 1b f4 ff ff ff ff 01 04 00
> 00:02:12.752730 (0001.38 ms) xid:rsp f41be1cd < 0c4619da S=6 s=4 Linux 
> hint=4400 [ Computer LAN Access ] (21)
>         fe bf 01 da 19 46 0c cd e1 1b f4 01 04 00 44 00
>         4c 69 6e 75 78
> =============
> 3. cat /proc/net/irda/discovery shows the output
> root@driver_s320:~# cat /proc/net/irda/discovery
> IrLMP: Discovery log:
>
> nickname: Linux, hint: 0x4400, saddr: 0xf41be1cd, daddr: 0x0c4619da
>
> 4. I run irattach /dev/ircomm0 -s on board 2 also
> 5. As a result, board 1 receives SNRM command. It sends the UA 
> response. However, it receives "sirdev_write_complete - schedule speed 
> change failed: -11" error multiple times.
> =======================
> 00:04:27.510549 (2114.77 ms) snrm:cmd ca=fe pf=1 f41be1cd < 0c4619da 
> new-ca=f4
>         LAP QoS: Baud Rate=9600bps Max Turn Time=500ms Data Size=2048B 
> Window Size=7 Add BOFS=0 Min Turn Time=10000us Link Disc=12s (32)
>         ff 93 da 19 46 0c cd e1 1b f4 f4 01 01 02 82 01
>         01 83 01 3f 84 01 7f 85 01 ff 86 01 01 08 01 07
> 00:04:27.512138 (0001.59 ms) ua:rsp ca=f4 pf=1 f41be1cd > 0c4619da
>         LAP QoS: Baud Rate=9600bps Max Turn Time=500ms Data Size=2048B 
> Window Size=7 Add BOFS=0 Min Turn Time=10000us Link Disc=12s (31)
>         f4 73 cd e1 1b f4 da 19 46 0c 01 01 02 82 01 01
>         83 01 3f 84 01 7f 85 01 ff 86 01 01 08 01 07
> 00:04:27.613760 (0101.62 ms) rr:cmd < ca=f4 pf=1 nr=0 (2)
>         f5 11
> 00:04:27.613952 (0000.19 ms) rr:rsp > ca=f4 pf=1 
> nrsirdev_write_complete - schedule speed change failed: -11
> =0 (2)
>         f4 11 sirdev_write_complete - schedule speed change failed: -11
>
> 00:04:27.61460sirdev_write_complete - schedule speed change failed: -11
> 2 (0000.65 ms) isirdev_write_complete - schedule speed change failed: -11
> :cmd < ca=f4 pfsirdev_write_complete - schedule speed change failed: -11
> =1 nr=0 ns=0 LM sirdev_write_complete - schedule speed change failed: -11
> slsap=12 dlsap=0sirdev_write_complete - schedule speed change failed: -11
> sirdev_write_complete - schedule speed change failed: -11
>
>         f5 10 80 12 01sirdev_write_complete - schedule speed change 
> failed: -11
>  00
> 00:04:27.615866 (0001.26 ms) i:rsp > ca=f4 pf=1 nr=1 ns=0 LM slsap=00 
> dlsap=12 CONN_RSP (6)
>         f4 30 92 00 81 00
> =======================
> 6. Board 2 receives following error messages.
> sirdev_receive - too early: c79e5026 / 30!
>
> 7. Few more messages are exchanged
> =======================
> 00:04:27.615866 (0001.26 ms) i:rsp > ca=f4 pf=1 nr=1 ns=0 LM slsap=00 
> dlsap=12 CONN_RSP (6)
>     f4 30 92 00 81 00
> 00:04:27.617376 (0001.51 ms) i:cmd < ca=f4 pf=1 nr=1 ns=1 LM slsap=12 
> dlsap=00 GET_VALUE_BY_CLASS: "IrDA:IrCOMM" "Parameters" (28)
>     f5 32 00 12 84 0b 49 72 44 41 3a 49 72 43 4f 4d
>     4d 0a 50 61 72 61 6d 65 74 65 72 73
> 00:04:27.617978 (0000.60 ms) i:rsp > ca=f4 pf=1 nr=2 ns=1 LM slsap=00 
> dlsap=12 GET_VALUE_BY_CLASS: Success
>     IrCOMM Parameters Service Type=NINE_WIRE THREE_WIRE Port Type=N/A 
> (19)
>     f4 52 12 00 84 00 00 01 23 43 02 00 06 00 01 06
>     01 01 00
> 00:04:27.620832 (0002.85 ms) i:cmd < ca=f4 pf=0 nr=2 ns=2 LM slsap=12 
> dlsap=00 DISC (6)
>     f5 44 80 12 02 01
> 00:04:27.621237 (0000.41 ms) i:cmd < ca=f4 pf=1 nr=2 ns=3 LM slsap=13 
> dlsap=00 CONN_CMD (6)
>     f5 56 80 13 01 00
> 00:04:27.622725 (0001.49 ms) i:rsp > ca=f4 pf=1 nr=4 ns=2 LM slsap=00 
> dlsap=13 CONN_RSP (6)
>     f4 94 93 00 81 00
> 00:04:27.624464 (0001.74 ms) i:cmd < ca=f4 pf=1 nr=3 ns=4 LM slsap=13 
> dlsap=00 GET_VALUE_BY_CLASS: "IrDA:IrCOMM" "IrDA:TinyTP:LsapSel" (37)
>     f5 78 00 13 84 0b 49 72 44 41 3a 49 72 43 4f 4d
>     4d 13 49 72 44 41 3a 54 69 6e 79 54 50 3a 4c 73
> 00:04:27.625088 (0000.62 ms) i:rsp > ca=f4 pf=1 nr=5 ns=3 LM slsap=00 
> dlsap=13 GET_VALUE_BY_CLASS: Success Integer: 11 (15)
>     f4 b6 13 00 84 00 00 01 23 43 01 00 00 00 11
> 00:04:27.627525 (0002.44 ms) i:cmd < ca=f4 pf=0 nr=4 ns=5 LM slsap=13 
> dlsap=00 DISC (6)
>     f5 8a 80 13 02 01
> 00:04:27.628016 (0000.49 ms) i:cmd < ca=f4 pf=1 nr=4 ns=6 LM slsap=11 
> dlsap=11 CONN_CMD TTP credits=16 (7)
>     f5 9c 91 11 01 00 10
> 00:04:27.629957 (0001.94 ms) i:rsp > ca=f4 pf=1 nr=7 ns=4 LM slsap=11 
> dlsap=11 CONN_RSP TTP credits=16 (7)
>     f4 f8 91 11 81 00 10
> 00:04:27.633168 (0003.21 ms) i:cmd < ca=f4 pf=1 nr=5 ns=7 LM slsap=11 
> dlsap=11 TTP credits=0
>     IrCOMM Service Type=NINE_WIRE Data Rate=9600 Data Format=13 Flow 
> Control=00 DTEline State=0c (24)
>     f5 be 11 11 00 12 00 01 04 10 04 00 00 25 80 11
>     01 13 12 01 00 20 01 0c
> 00:04:27.634586 (0001.42 ms) rr:rsp > ca=f4 pf=1 nr=0 (2)
>     f4 11
> 00:04:27.642005 (0007.42 ms) xid:cmd f168e953 > ffffffff S=6 s=1 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 01 00
> 00:04:27.648576 (0006.57 ms) xid:cmd f168e953 > ffffffff S=6 s=2 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 02 00
> 00:04:27.655098 (0006.52 ms) xid:cmd f168e953 > ffffffff S=6 s=3 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 03 00
> 00:04:27.661669 (0006.57 ms) xid:cmd f168e953 > ffffffff S=6 s=4 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 04 00
> 00:04:27.668240 (0006.57 ms) xid:cmd f168e953 > ffffffff S=6 s=5 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 05 00
> 00:04:27.674762 (0006.52 ms) xid:cmd f168e953 > ffffffff S=6 s=* 
> driver_s320 hint=c404 [ Computer LAN Access IrCOMM ] (28)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 ff 00 c4 04
>     00 64 72 69 76 65 72 5f 73 33 32 30
> 00:04:27.681333 (0006.57 ms) xid:cmd f168e953 > ffffffff S=6 s=0 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 00 00
> 00:04:27.687904 (0006.57 ms) xid:cmd f168e953 > ffffffff S=6 s=1 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 01 00
> 00:04:27.806010 (0118.11 ms) xid:cmd f168e953 > ffffffff S=6 s=0 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 00 00
> 00:04:28.133157 (0327.15 ms) rr:cmd < ca=f4 pf=1 nr=5 (2)
>     f5 b1
> 00:04:28.133402 (0000.25 ms) i:rsp > ca=f4 pf=0 nr=0 ns=5 LM slsap=11 
> dlsap=11 TTP credits=1
>     IrCOMM Data Rate=9600 Data Format=13 Flow Control=00 DTEline 
> State=0c (21)
>     f4 0a 11 11 01 0f 10 04 00 00 25 80 11 01 13 12
>     01 00 20 01 0c
> 00:04:28.134314 (0000.91 ms) i:rsp > ca=f4 pf=0 nr=0 ns=6 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 0c 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 00
> 00:04:28.135557 (0001.24 ms) i:rsp > ca=f4 pf=0 nr=0 ns=7 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 0e 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 01
> 00:04:28.136298 (0000.74 ms) xid:cmd f168e953 > ffffffff S=6 s=1 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 01 00
> 00:04:28.136645 (0000.35 ms) i:rsp > ca=f4 pf=0 nr=0 ns=0 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 00 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 02
> 00:04:28.136912 (0000.27 ms) xid:cmd f168e953 > ffffffff S=6 s=2 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 02 00
> 00:04:28.137413 (0000.50 ms) xid:cmd f168e953 > ffffffff S=6 s=3 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 03 00
> 00:04:28.137738 (0000.32 ms) i:rsp > ca=f4 pf=0 nr=0 ns=1 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 02 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 03
> 00:04:28.138832 (0001.09 ms) i:rsp > ca=f4 pf=0 nr=0 ns=2 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 04 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 04
> 00:04:28.139898 (0001.07 ms) i:rsp > ca=f4 pf=1 nr=0 ns=3 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 16 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 05
> 00:04:28.141216 (0001.32 ms) rr:cmd < ca=f4 pf=1 nr=7 (2)
>     f5 f1
> 00:04:28.141370 (0000.15 ms) i:rsp > ca=f4 pf=0 nr=0 ns=7 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 0e 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 01
> 00:04:28.142453 (0001.08 ms) i:rsp > ca=f4 pf=0 nr=0 ns=0 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 00 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 02
> 00:04:28.143541 (0001.09 ms) i:rsp > ca=f4 pf=0 nr=0 ns=1 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 02 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 03
> 00:04:28.144629 (0001.09 ms) i:rsp > ca=f4 pf=0 nr=0 ns=2 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 04 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 04
> 00:04:28.145765 (0001.14 ms) i:rsp > ca=f4 pf=1 nr=0 ns=3 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 16 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 05
> 00:04:28.147157 (0001.39 ms) rr:cmd < ca=f4 pf=1 nr=0 (2)
>     f5 11
> 00:04:28.147322 (0000.17 ms) i:rsp > ca=f4 pf=0 nr=0 ns=0 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 00 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 02
> 00:04:28.148405 (0001.08 ms) i:rsp > ca=f4 pf=0 nr=0 ns=1 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 02 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 03
> 00:04:28.149498 (0001.09 ms) i:rsp > ca=f4 pf=0 nr=0 ns=2 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 04 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 04
> 00:04:28.150581 (0001.08 ms) i:rsp > ca=f4 pf=1 nr=0 ns=3 LM slsap=11 
> dlsap=11 TTP credits=0 IrCOMM (36)
>     f4 16 11 11 00 00 ff ff ff ff ff ff ff ff ff ff
>     ff ff c0 ff 3f 01 53 e9 68 f1 ff ff ff ff 01 05
>
> 8. In between the board 1 sends few XID commands with changed HW address.
> 00:04:28.165952 (0015.37 ms) xid:cmd f168e953 > ffffffff S=6 s=4 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 04 00
> 00:04:28.255925 (0089.97 ms) xid:cmd f168e953 > ffffffff S=6 s=5 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 05 00
> 00:04:28.345898 (0089.97 ms) xid:cmd f168e953 > ffffffff S=6 s=* 
> driver_s320 hint=c404 [ Computer LAN Access IrCOMM ] (28)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 ff 00 c4 04
>     00 64 72 69 76 65 72 5f 73 33 32 30
> 00:04:30.816069 (2470.17 ms) xid:cmd f168e953 > ffffffff S=6 s=0 (14)
>     ff 3f 01 53 e9 68 f1 ff ff ff ff 01 00 00
>
> 9. Then few logs of no activity on the link are received:
> IrLAP, no activity on link!
> IrLAP, no activity on link!
> IrLAP, no activity on link!
> IrLAP, no activity on link!
>
> 10. The board 1 again sends XID commands with *original* HW address. 
> Board 2 also sends the XID commands
> 11. XID response is sent by both the boards to each other. Now, the 
> hint field is not c404 but 4400. hint becomes c404 when we run 
> irattach /dev/ircomm0. Before that it is 4400 (by default)
> ==================
> 00:04:58.208341 (0001.47 ms) xid:rsp f41be1cd < 0c4619da S=6 s=3 
> driver_s310 hint=4400 [ Computer LAN Access ] (27)
>     fe bf 01 da 19 46 0c cd e1 1b f4 01 03 00 44 00
>     64 72 69 76 65 72 5f 73 33 31 30
> 00:04:58.306869 (0098.53 ms) xid:cmd f41be1cd > ffffffff S=6 s=4 (14)
>     ff 3f 01 cd e1 1b f4 ff ff ff ff 01 04 00
> 00:04:58.406874 (0100.00 ms) xid:cmd f41be1cd > ffffffff S=6 s=5 (14)
>     ff 3f 01 cd e1 1b f4 ff ff ff ff 01 05 00
> 00:04:58.506880 (0100.01 ms) xid:cmd f41be1cd > ffffffff S=6 s=* 
> driver_s320 hint=4400 [ Computer LAN Access ] (27)
>     ff 3f 01 cd e1 1b f4 ff ff ff ff 01 ff 00 44 00
>     64 72 69 76 65 72 5f 73 33 32 30
> 00:04:58.744384 (0237.50 ms) xid:cmd ffffffff < 0c4619da S=6 s=0 (14)
>     ff 3f 01 da 19 46 0c ff ff ff ff 01 00 00
> 00:04:58.844277 (0099.89 ms) xid:cmd ffffffff < 0c4619da S=6 s=1 (14)
>     ff 3f 01 da 19 46 0c ff ff ff ff 01 01 00
> 00:04:58.944277 (0100.00 ms) xid:cmd ffffffff < 0c4619da S=6 s=2 (14)
>     ff 3f 01 da 19 46 0c ff ff ff ff 01 02 00
> 00:04:58.944485 (0000.21 ms) xid:rsp f41be1cd > 0c4619da S=6 s=2 
> driver_s320 hint=4400 [ Computer LAN Access ] (27)
>     fe bf 01 cd e1 1b f4 da 19 46 0c 01 02 00 44 00
>     64 72 69 76 65 72 5f 73 33 32 30
> ==================
> 12. cat /proc/net/irda/discovery shows the following output.
> ==================
> root@driver_s320:~# cat /proc/net/irda/discovery
> IrLMP: Discovery log:
>
> nickname: driver_s310, hint: 0x4400, saddr: 0xf41be1cd, daddr: 0x0c4619da
> ==================
> 13. The above XID CMD/RSP sequence goes on and on.
>
> I shall be very much thankful for any support
>
> ~Amit Virdi
>
> On 4/13/2011 12:10 PM, Amit Virdi wrote:
>> Hi All,
>>
>> For the past few days I've been trying to test a driver that I've 
>> written for DICE Fast IrDA controller. As per my requirements, I need 
>> to use IrCOMM as the upper layer.
>>
>> I'm using the same kernel image on the both the boards. When I run 
>> irattach on either of the boards I can see discovery protocol being 
>> initiated and completing successfully (cat /proc/net/irda/discovery 
>> giving output with other ends's device's MAC address as the daddr) 
>> but I'm struggling to test the driver further.
>>
>> I've observed that the discovery request/response sequence goes on 
>> for 5 minutes. After this, the discovery process stops. On the master 
>> side, I could see no IrLAP frame being sent/received and also the 
>> output of cat /proc/net/irda/discovery is NULL. However, on the slave 
>> side, the cat /proc/net/irda/discovery output shows the master side!!
>>
>> If I run irattach on the slave side also, no DISCOVERY message is 
>> exchanged and then, the output of slave side also doesn't show anything.
>>
>> Sometimes, I start getting log "IrLAP, no activity on link!" and then 
>> ircomm_close() API is called from within the stack.
>>
>> If, I try to run getty on /dev/ircomm0, it does not work!
>>
>> If I try to transfer data using
>>     echo "1234567890" > /dev/ircomm0
>> on the master side, and
>>     cat /dev/ircomm0
>> on the slave side, I can see SNRM command, UA response, RR command, 
>> IrLMP connect/disconnect etc. However, the data transfer actually 
>> didn't happen. I cannot see the string "1234567890" on the slave side.
>>
>> Please suggest what I'm missing/doing wrong. I need to transfer data 
>> from one device to another to complete the testing. I shall be very 
>> much thankful for suggestions/advice.
>>
>> Thanks n Regards
>> Amit Virdi
