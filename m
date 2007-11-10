From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 16:16:41 +0100
Message-ID: <4735CB59.2050708@cosmosbay.com>
References: <20071110131428.GA6447@gondor.apana.org.au> <20071110.223243.114494952.yoshfuji@linux-ipv6.org> <20071110143325.GA6888@gondor.apana.org.au> <20071110.234854.10674315.yoshfuji@linux-ipv6.org> <20071110145536.GA7024@gondor.apana.org.au> <4735C8E9.4030401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58637 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbXKJPRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 10:17:00 -0500
In-Reply-To: <4735C8E9.4030401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
> Herbert Xu a =C3=A9crit :
>> On Sat, Nov 10, 2007 at 11:48:54PM +0900, YOSHIFUJI Hideaki / =E5=90=
=89=E8=97=A4=E8=8B=B1=E6=98=8E=20
>> wrote:
>>> Hmm..... "netstat -s" from etch (i386) and etch (x86_64) work
>>> fine for me.  Same version, same architecture.  Strange...
>>
>> Interesting.  What does your /proc/net/snmp file look like?
>> And what does netstat -s actually produce?
>>
>> Thanks,
>=20
> Quite easy :)
>=20
> A failing one is > 1024 bytes :
>=20
> Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors=20
> ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests=20
> OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails=20
> FragOKs FragFails FragCreates
> Ip: 2 64 6954137412 0 23489 0 125 0 6790615249 6423886499 2706 0 1388=
1=20
> 164999330 1503683 34165124 1219558 188 54871924
> Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs=20
> InSrcQuenchs InRedirects InEchos InEchoReps InTimestamps InTimestampR=
eps=20
> InAddrMasks InAddrMaskReps OutMsgs OutErrors OutDestUnreachs=20
> OutTimeExcds OutParmProbs OutSrcQuenchs OutRedirects OutEchos=20
> OutEchoReps OutTimestamps OutTimestampReps OutAddrMasks OutAddrMaskRe=
ps
> Icmp: 6392743 1256162 3894707 401904 83 20702 172602 1415531 0 3 0 3 =
0=20
> 106773069 0 3894707 401904 83 20702 172602 1415531 0 3 0 3 0
> IcmpMsg: InType3 InType4 InType5 InType8 InType11 InType12 InType13=20
> InType17 OutType0 OutType3 OutType11 OutType14
> IcmpMsg: 3894707 20702 172602 1415531 401904 83 3 3 1414557 105347007=
=20
> 11502 3
> Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens=20
> AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs=20
> OutRsts
> Tcp: 1 200 120000 -1 62967275 66063269 17969333 24912734 1278435=20
> 6041838336 5717892916 279078174 361708 35913131
> Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErr=
ors
> Udp: 640604836 101598293 193394 421746699 133903 0
> UdpLite: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors=20
> SndbufErrors
> UdpLite: 0 0 0 0 0 0
>=20
>=20
> So netstat fails because line 344 in statistics.c :
>=20
> buf1=3DTcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed=20
> EmbryonicRsts PruneCalled RcvPruned OfoPruned OutOfWindowIcmps=20
> LockDroppedIcmps ArpFilter TW TWRecycled TWKilled PAWSPassive PAWSAct=
ive=20
> PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost ListenOverflows=
=20
> ListenDrops TCPPrequeued TCPDirectCopyFromBacklog=20
> TCPDirectCopyFromPrequeue TCPPrequeueDropped TCPHPHits TCPHPHitsToUse=
r=20
> TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSackRecovery TCPSACKReneging=
=20
> TCPFACKReorder TCPSACKReorder TCPRenoReorder TCPTSReorder TCPFullUndo=
=20
> TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit=20
> TCPRenoFailures TCPSackFailures TCPLossFailures TCPFastRetrans=20
> TCPForwardRetrans TCPSlowStartRetrans TCPTimeouts TCPRenoRecoveryFail=
=20
> TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollapsed TCPDSACKOldSen=
t=20
> TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbortOnSyn=20
> TCPAbortOnData TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout=20
> TCPAbortOnLinger TCPAbortFailed TCPMemoryPressures TCPSACKDiscard=20
> TCPDSACKIgnoredOld TCPDSACKIgnoredNoUndo buf2=3D TCPSpuriousRTOs
>=20
>=20
> So this is an existing kernel bug, not related to UDPlite

I meant a netstat bug of course, sorry :(

It fails to parse /proc/net/netstat , because TcpExt line is bigger tha=
n 1024=20
chars.

To correct it, we might enlarge buf1[] and buf2[] from 1024 to 2048 in=20
statistics.c, process_fd() function.


