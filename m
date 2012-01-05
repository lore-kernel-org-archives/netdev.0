From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 05 Jan 2012 11:26:33 -0800
Message-ID: <4F05F969.7090608@hp.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com> <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com> <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com> <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F0382BB.5060601@hp.com> <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com> <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=jyzV6BwB6Lce0CCi+Z3MuwNsWLw2DQu8HBdm_J8kvArA@mail.gmail.com> <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=hGnnuXf+cETy9fAeu+aACp2pfL3XfBS_jL_mk38fj4yQ@mail.gmail.com> <1325757891.2415.7.camel@edumazet-HP-Co
 mpaq-6005-Pro-SFF-PC> <4F05EECE.1000708@hp.com> <1325789604.4759.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Michel Hautbois <jhautbois@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:23098 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab2AET0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:26:35 -0500
In-Reply-To: <1325789604.4759.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2012 10:53 AM, Eric Dumazet wrote:
> Le jeudi 05 janvier 2012 =C3=A0 10:41 -0800, Rick Jones a =C3=A9crit =
:
>
>> Why?  A netperf UDP_STREAM test is "purely" unidirectional (*).  I
>> suspect the numbers look funny thanks to the 32-bit compilation bugs
>> (format statement issues).
>
> Unidirectional, but the receiver must send some status notifications =
?
>
> My reasonning (before you explained the compat problem between sender
> and receiver) was that since we flooded the link, we were blocking
> output from receiver (because of collisions), and

Well, the flow goes something like

*) netperf establishes control connection
*) netserver accepts and forks
*) netperf sends initial test request and configuration
*) netserver sends final test setup information
*) netserver starts timer (with padding)
*) netperf starts timer
*) netperf's timer expires, netperf stops sending, starts waiting for=20
results from netserver (in a select with a one or two minute timeout)
*) netserver's timer expires, sends its part of the test results
*) netperf comes out of select and receives netservers information
*) netperf displays results

If the netserver's results were blocked by some massive backlog of data=
=20
in queues somewhere, the results will either simply be delayed, or=20
netperf's select() will timeout and errors will be reported.  It would=20
not result in netperf reporting results without netserver's input.

happy benchmarking,

rick jones
