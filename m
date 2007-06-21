From: jamal <hadi@cyberus.ca>
Subject: FSCKED clock sources WAS(Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 21 Jun 2007 11:54:17 -0400
Message-ID: <1182441257.5017.48.camel@localhost>
References: <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <20070619.152801.99185860.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wZ+pykPA+5ASPePiUDXs"
Cc: Robert.Olsson@data.slu.se, johnpol@2ka.mipt.ru,
	krkumar2@in.ibm.com, gaagaan@gmail.com, netdev@vger.kernel.org,
	rick.jones2@hp.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:36023 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757119AbXFUPyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 11:54:22 -0400
Received: by wx-out-0506.google.com with SMTP id t15so552830wxc
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 08:54:21 -0700 (PDT)
In-Reply-To: <20070619.152801.99185860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wZ+pykPA+5ASPePiUDXs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2007-19-06 at 15:28 -0700, David Miller wrote:

> Converting pktgen over to ktime_t might be a nice cleanup.

Would that really solve it? i.e doesnt it still tie to what the clock
source is?

I had a friend of mine (Robert, you know Jeremy) and results are
slightly different from what Evginy found.

The summary is: Batching always is better, jiffies is always the better
clock source (and who would have thunk,eh? Opteron kicks a Xeons ass).
Attached results.

Evgeniy, did you sync on the batching case with the git tree?
Can you describe your hardware in /proc/cpuinfo and /proc/interupts?

cheers,
jamal

--=-wZ+pykPA+5ASPePiUDXs
Content-Disposition: attachment; filename=batch-clock-res
Content-Type: text/plain; name=batch-clock-res; charset=us-ascii
Content-Transfer-Encoding: 7bit

The test variables are:
----------------------

1) A Intel Xeon[1] machine vs an AMD opteron[2].
2) A plain 2622-rc4 kernel vs a 2622-rc4 with batching
(from git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git)
3) Different clock sources acpi-pm, jiffies and tsc

Test setup
-----------

pktgen was used to send from the system under test (where
test variables #2-#3 were adjusted) to a second box. 
CPU affinity was tied to cpu2 in all case to reduce variables in all test 
cases...

Test validation
---------------

Throughput results were confirmed to match on receiver
and sender (as reported by pktgen)

Results
-------
The AMD opteron always had better results.
The batching kernels always was better than non-batching.
The jiffies clock was always the most consistent and gave
best performance

Kernel-type | acpi-pm clock | jiffies clock | tsc clock |
+h/ware     |               |               |           |
------------+---------------+---------------+-----------+
2622-rc4    | 347Kpps       | 1.40 Mpps     | 1.36Mpps  |
plain       |               |               |           |
Intel Xeon  |               |               |           |
------------+---------------+---------------+-----------+
2622-rc4    | 342Kpps       | 853 kpps      | 821kpps   |
plain       |               |               |           |
AMD opteron |               |               |           |
------------+---------------+---------------+-----------+
2622-rc4    | 615Kpps       | 1.46 Mpps     | 1.46Mpps  |
batch       |               |               |           |
Intel Xeon  |               |               |           |
------------+---------------+---------------+-----------+
2622-rc4    | 633Kpps       | 1.18 Mpps     | 1.17Mpps  |
batch       |               |               |           |
AMD opteron |               |               |           |
------------+---------------+---------------+-----------+

The two systems under test 
---------------------------

[1]-------------
vendor_id       : GenuineIntel
cpu family      : 15
model           : 4
model name      : Intel(R) Xeon(TM) CPU 2.80GHz
stepping        : 1
cpu MHz         : 2793.329
cache size      : 1024 KB
physical id     : 3
siblings        : 2
core id         : 0
cpu cores       : 1
-------------

[2]-------------
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 33
model name      : Dual Core AMD Opteron(tm) Processor 275
stepping        : 2
cpu MHz         : 2194.778
cache size      : 1024 KB
physical id     : 1
siblings        : 2
core id         : 1
cpu cores       : 2
---------------------------------------------


--=-wZ+pykPA+5ASPePiUDXs--

