From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: 3945 driver using d80211
Date: Tue, 08 Aug 2006 14:27:37 -0700
Message-ID: <44D901C9.6090304@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:41232 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S1030304AbWHHV1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 17:27:44 -0400
Received: from [134.134.16.71] (mabbas-mobl1.amr.corp.intel.com [134.134.16.71])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k78LRdxR006941
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 21:27:39 GMT
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
I am currently working on porting 3945 driver to use d80211. The portin=
g=20
is going well, thanks for the great stack. I ran into some problems and=
=20
issues that I had to use some work around to have it functioning. I hop=
e=20
I can find the help to point me to right way of using the stack.

1- I needed to use sta_info_get function to do rate scaling for 3945,=20
although this function is exported but it was missing from d80211.h, fo=
r=20
work around I had to copy more header files to my driver's directory, I=
t=20
this plan to add this function to d80211.h ?

2- Scanning; in 3945 driver, we can not tune to other channels while we=
=20
are connected, this will cause a firmware error. The firmware provides =
a=20
scanning command we call so the firmware will take care of switching of=
=20
the available channels and gather beacons and probe responses. The=20
current d80211 the stack will call config callback to switch to=20
different channel and send the probe requests. One of our engineers did=
=20
come up with a patch to add one more callback function if provided the=20
d80211 will call this function to allow the registered driver to perfor=
m=20
the scanning functionalities. For work around I currently check inside=20
config callback if the scanning flag set I will issues the scan command=
=20
then ignore the next config callback.

3- I can not access beacon's info from current associated AP.=20
information I need to callback into the firmware like timestamp and aid=
,=20
work around I would parse incoming management frame and filter beacon=20
from associated AP to get this info. This is a duplicate code that=20
d80211 stack doing, maybe there is away to get these info that I don=92=
t=20
know of. Also it will be nice to have some callback function on=20
association, disassociation.

4- I am been using the driver for sometime right now and it seems to be=
=20
stable and liable although I am using SMP system. I hearted of some SMP=
=20
issues in d80211 and I have the machine and time to help in this. Do yo=
u=20
have any test script the cause this SMP problems? Or steps to reproduce=
 it.

again thanks alot for the great work on d80211.

Thanks

Mohamed Abbas
