From: kuznet@ms2.inr.ac.ru
Subject: Re: TCP advertized window
Date: Sat, 20 Jul 2002 05:26:10 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207200126.FAA01451@sex.inr.ac.ru>
References: <200207190658.MAA21653@eis.iisc.ernet.in>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: anand@eis.iisc.ernet.IN (SVR Anand)
In-Reply-To: <200207190658.MAA21653@eis.iisc.ernet.in> from "SVR Anand" at Jul 19, 2 11:15:00 am
List-Id: netdev.vger.kernel.org

Hello!

> Can you let me know what is the mechanism used in computing the advertised 
> window ?

It is initialized to 3*mss (actually, 2...4*mss, look into include/net/tcp.h
tcp_select_initial_window() for details). Then each arriving segment
it is increased by 2*mss until it reaches maximal value (if the segment
does not have pathological ratio real_bits/overhead, see tcp_grow_window()).

Maximum depends only on rcvbuf and mss.

If pathological overflow of rcvbuf still happens,
window may be reset back to initial value.

Alexey
