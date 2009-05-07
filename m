From: Matthias Saou
	<thias@spam.spam.spam.spam.spam.spam.spam.egg.and.spam.freshrpms.net>
Subject: Re: Wrong network usage reported by /proc
Date: Thu, 7 May 2009 19:58:27 +0200
Message-ID: <20090507195827.3bbdb4ff@python3.es.egwn.lan>
References: <20090504171408.3e13822c@python3.es.egwn.lan>
	<49FF2BB2.4030700@cosmosbay.com>
	<20090504211151.74622f29@python3.es.egwn.lan>
	<20090505050435.GK570@1wt.eu>
	<49FFCD08.7050600@cosmosbay.com>
	<20090505055032.GA29582@1wt.eu>
	<20090505100939.1e0932c4@python3.es.egwn.lan>
	<49FFFE2D.9080509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/Jaz4MsxH5DQQEvSLTy5sJoD"
To: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx32b01.es6.egwn.net ([195.10.6.123]:56446 "EHLO
	mx1.es6.egwn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498AbZEGR6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 13:58:31 -0400
In-Reply-To: <49FFFE2D.9080509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/Jaz4MsxH5DQQEvSLTy5sJoD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Eric Dumazet wrote :

> Matthias Saou a =E9crit :
> > Willy Tarreau wrote :
> >=20
> >> On Tue, May 05, 2009 at 07:22:16AM +0200, Eric Dumazet wrote:
> >>> Willy Tarreau a =E9crit :
> >>>> On Mon, May 04, 2009 at 09:11:51PM +0200, Matthias Saou wrote:
> >>>>> Eric Dumazet wrote :
> >>>>>
> >>>>>> Matthias Saou a =E9crit :
> >>>>>>> Hi,
> >>>>>>>
> >>>>>>> I'm posting here as a last resort. I've got lots of heavily used =
RHEL5
> >>>>>>> servers (2.6.18 based) that are reporting all sorts of impossible
> >>>>>>> network usage values through /proc, leading to unrealistic snmp/c=
acti
> >>>>>>> graphs where the outgoing bandwidth used it higher than the physi=
cal
> >>>>>>> interface's maximum speed.
> >>>>>>>
> >>>>>>> For some details and a test script which compares values from /pr=
oc
> >>>>>>> with values from tcpdump :
> >>>>>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D489541
> >>>>>>>
> >>>>>>> The values collected using tcpdump always seem realistic and matc=
h the
> >>>>>>> values seen on the remote network equipments. So my obvious concl=
usion
> >>>>>>> (but possibly wrong given my limited knowledge) is that something=
 is
> >>>>>>> wrong in the kernel, since it's the one exposing the /proc interf=
ace.
> >>>>>>>
> >>>>>>> I've reproduced what seems to be the same problem on recent kerne=
ls,
> >>>>>>> including the 2.6.27.21-170.2.56.fc10.x86_64 I'm running right no=
w. The
> >>>>>>> simple python script available here allows to see it quite easily=
 :
> >>>>>>> https://www.redhat.com/archives/rhelv5-list/2009-February/msg0016=
6.html
> >>>>>>>
> >>>>>>>  * I run the script on my Workstation, I have an FTP server enabl=
ed
> >>>>>>>  * I download a DVD ISO from a remote workstation : The values ma=
tch
> >>>>>>>  * I start ping floods from remote workstations : The values repo=
rted
> >>>>>>>    by /proc are much higher than the ones reported by tcpdump. I =
used
> >>>>>>>    "ping -s 500 -f myworkstation" from two remote workstations
> >>>>>>>
> >>>>>>> If there's anything flawed in my debugging, I'd love to have some=
one
> >>>>>>> point it out to me. TIA to anyone willing to have a look.
> >>>>>>>
> >>>>>>> Matthias
> >>>>>>>
> >>>>>> I could not reproduce this here... what kind of NIC are you using =
on
> >>>>>> affected systems ? Some ethernet drivers report stats from card it=
self,
> >>>>>> and I remember seeing some strange stats on some hardware, but I c=
annot
> >>>>>> remember which one it was (we were reading NULL values instead of
> >>>>>> real ones, once in a while, maybe it was a firmware issue...)
> >>>>> My workstation has a Broadcom BCM5752 (tg3 module). The servers whi=
ch
> >>>>> are most affected have Intel 82571EB (e1000e). But the issue is that
> >>>>> with /proc, the values are a lot _higher_ than with tcpdump, and the
> >>>>> tcpdump values seem to be the correct ones.
> >>>> the e1000 chip reports stats every 2 seconds. So you have to collect
> >>>> stats every 2 seconds otherwise you get "camel-looking" stats.
> >>>>
> >>> I looked at e1000e driver, and apparently tx_packets & tx_bytes are c=
omputed
> >>> by the TX completion routine, not by the chip.
> >> Ah I thought that was the chip which returned those stats every 2 seco=
nds,
> >> otherwise I don't see the reason to delay their reporting. Wait, I'm s=
peaking
> >> about e1000, never tried e1000e. Maybe there have been changes there. =
Anyway,
> >> Matthias talked about RHEL5's 2.6.18 in which I don't think there was =
e1000e.
> >>
> >> Anyway we did not get any concrete data for now, so it's hard to tell =
(I
> >> haven't copy-pasted the links above in my browser yet).
> >=20
> > If you need any more data, please just ask. What makes me wonder most,
> > though, is that tcpdump and iptraf report what seem to be correct
> > bandwidth values (they seem to use the same low level access for their
> > counters) whereas snmp and ifconfig (which seem to use /proc for
> > theirs) report unrealistically high values.
> >=20
> > The tcpdump vs. /proc would be the first thing to look at, since it
> > might give hints as to where the problem might lie, no?
> >=20
> > From there, I could collect any data one might find relevant to
> > diagnose further.
> >=20
> > I'm attaching the simple python script I've used for testing.
> >=20
> > Matthias
> >=20
> >=20
>=20
> Your python script is buggy, since space after ':' is optional
[...]

You are right. The script isn't mine originally. I've reviewed and
modified an updated version, attached to this email, which should fix
this as well as other issues, and be more readable.

I've re-done some testing and it seems like I'm not able to reproduce
the problem except on the 32bit RHEL5.2 servers where it's VERY
noticeable.

Sample output :
TCPDUMP: 82189861266 (56100271 packets)
PROC:    764627087298 (59162342 packets)

Yes, /proc/net/dev is reporting nearly 10 times more bytes than the sum
of what tcpdump reports in its "length x" fields. This is about what I
see on my snmp graphs : little more than 100Mbps reported from the
switch when the server reports 1Gbps.

The Red Hat bugzilla entry has been updated, and the issue is surely
better off tracked there. My current guess would also be a bug in the
e1000e module...

But if this rings a bell to anyone, please poke me! The module I'm using
is this one :

filename:       /lib/modules/2.6.18-92.1.10.el5PAE/kernel/drivers/net/e1000=
e/e1000e.ko
version:        0.2.0
license:        GPL
description:    Intel(R) PRO/1000 Network Driver
author:         Intel Corporation, <linux.nics@intel.com>
srcversion:     7DD4D251CA27FFAE6342F30

Thanks all for your feedback and sorry for the wrong initial script.

Matthias

--=20
Clean custom Red Hat Linux rpm packages : http://freshrpms.net/
Fedora release 10 (Cambridge) - Linux kernel
2.6.27.21-170.2.56.fc10.x86_64 Load : 0.34 0.21 0.19

--MP_/Jaz4MsxH5DQQEvSLTy5sJoD
Content-Type: text/x-python
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=monitor.py

#!/usr/bin/python
#
# Simple script to print out realtime byte and packet traffic count on an
# interface using both tcpdump output and /proc/net/dev content
#
# Last change : 20090507
#

import re
import time
import thread
import getopt
import signal
import sys
from subprocess import Popen, PIPE, STDOUT

# TODO print not refreshing correctly

# tx[0] are tx_bytes
# tx[1] are tx_packets
def get_tx_from_tcpdump(interface, tx):
    command = Popen(['tcpdump', '-n', '-e', '-p', '-l', '-v', '-i',
                     interface], stdout=PIPE, stderr=PIPE,
                     bufsize=1) # line buffering, optimizes a lot
    while 1:
        line = command.stdout.readline()
        if not line:
            # time.sleep(1)
            continue
        # Extract the nnn from the ", length nnn)" part of the line
        bytes_pattern = re.search('length (\d+)', line)

        if bytes_pattern:
            tx[0] += int(bytes_pattern.group(1))
            tx[1] += 1
        else:
            # ARP packet or other output... could be 28 + 14, but just ignore
            bytes = 0

        # Don't wait
        #time.sleep(1)

# tx[0] are tx_bytes
# tx[1] are tx_packets
def get_tx_from_proc(interface, tx):
    wrap = 2**32
    # Get the initial values
    tx_bytes_prev, tx_packets_prev = read_proc_tx(interface)
    # Something went wrong...
    if tx_bytes_prev is None or tx_packets_prev is None:
        s = ("Could not read data from /proc/net/dev. "
             "I was looking for the interface %s." % interface)
        tx[0] = s
        return None
    # Main loop to update tx data values
    while(1):
        tx_bytes, tx_packets = read_proc_tx(interface)
        # Get the difference wrt the previous poll
        tx_bytes_diff = tx_bytes - tx_bytes_prev
        tx_packets_diff = tx_packets - tx_packets_prev
        # Check for an eventual wrap and re-ajust
        if tx_bytes_diff < 0:
            tx_bytes_diff = (wrap - (tx[0] % wrap)) + tx_bytes
            print "*** Bytes wrap! (from %s to %s)" % (tx_bytes_prev, tx_bytes)
        if tx_packets_diff < 0:
            tx_packets_diff = (wrap - (tx[1] % wrap)) + tx_packets
        # Update our counters
        tx[0] += tx_bytes_diff
        tx[1] += tx_packets_diff
        tx_bytes_prev = tx_bytes
        tx_packets_prev = tx_packets
        # Wait
        time.sleep(1)

# Return an array of tx[bytes, packets]
def read_proc_tx(interface):
    f = open('/proc/net/dev')
    for line in f:
        values = line.split(":")
        i = values[0].replace(' ', '')
        if interface == i:
            tx = [int(values[1].split()[8]), int(values[1].split()[9])]
            f.close()
            return tx
    f.close()

def signal_handler(signum, frame):
    sys.exit(0)

def main(interface):
    signal.signal(signal.SIGINT, signal_handler)

    tx_tcpdump = [0, 0]
    tx_proc = [0, 0]

    thread.start_new_thread(get_tx_from_tcpdump, (interface, tx_tcpdump))
    thread.start_new_thread(get_tx_from_proc, (interface, tx_proc))

    while 1:
        tcpdump_bytes = tx_tcpdump[0]
        tcpdump_packets = tx_tcpdump[1]
        proc_bytes = tx_proc[0]
        proc_packets = tx_proc[1]

        if type(proc_bytes) == type('0'):
            print "Error: %s" % proc_bytes
            sys.exit(0)
        s = "TCPDUMP: %d (%d packets)\nPROC:    %d (%d packets)" % (
                tcpdump_bytes, tcpdump_packets, proc_bytes, proc_packets )
        print s
        time.sleep(1)

def usage():
    print "Usage: monitor -i <interface> (e.g. eth0)"

if __name__ == "__main__":
    interface = None
    ip = None
    opts, args = getopt.getopt(sys.argv[1:], "hi:", ["help"])
    for o, a in opts:
        if o == '-i':
            interface = a
        elif o in ['-h', '--help']:
            usage()
            sys.exit()
    if not interface:
        usage()
        sys.exit()

    main(interface)


--MP_/Jaz4MsxH5DQQEvSLTy5sJoD--
