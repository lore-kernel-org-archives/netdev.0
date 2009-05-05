From: Matthias Saou
	<thias@spam.spam.spam.spam.spam.spam.spam.egg.and.spam.freshrpms.net>
Subject: Re: Wrong network usage reported by /proc
Date: Tue, 5 May 2009 10:09:39 +0200
Message-ID: <20090505100939.1e0932c4@python3.es.egwn.lan>
References: <20090504171408.3e13822c@python3.es.egwn.lan>
	<49FF2BB2.4030700@cosmosbay.com>
	<20090504211151.74622f29@python3.es.egwn.lan>
	<20090505050435.GK570@1wt.eu>
	<49FFCD08.7050600@cosmosbay.com>
	<20090505055032.GA29582@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/l6Kc96JmQ=e_4SXVT+=usdR"
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx32b01.es6.egwn.net ([195.10.6.123]:51074 "EHLO
	mx1.es6.egwn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbZEEIJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 04:09:41 -0400
In-Reply-To: <20090505055032.GA29582@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/l6Kc96JmQ=e_4SXVT+=usdR
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Willy Tarreau wrote :

> On Tue, May 05, 2009 at 07:22:16AM +0200, Eric Dumazet wrote:
> > Willy Tarreau a =E9crit :
> > > On Mon, May 04, 2009 at 09:11:51PM +0200, Matthias Saou wrote:
> > >> Eric Dumazet wrote :
> > >>
> > >>> Matthias Saou a =E9crit :
> > >>>> Hi,
> > >>>>
> > >>>> I'm posting here as a last resort. I've got lots of heavily used R=
HEL5
> > >>>> servers (2.6.18 based) that are reporting all sorts of impossible
> > >>>> network usage values through /proc, leading to unrealistic snmp/ca=
cti
> > >>>> graphs where the outgoing bandwidth used it higher than the physic=
al
> > >>>> interface's maximum speed.
> > >>>>
> > >>>> For some details and a test script which compares values from /proc
> > >>>> with values from tcpdump :
> > >>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D489541
> > >>>>
> > >>>> The values collected using tcpdump always seem realistic and match=
 the
> > >>>> values seen on the remote network equipments. So my obvious conclu=
sion
> > >>>> (but possibly wrong given my limited knowledge) is that something =
is
> > >>>> wrong in the kernel, since it's the one exposing the /proc interfa=
ce.
> > >>>>
> > >>>> I've reproduced what seems to be the same problem on recent kernel=
s,
> > >>>> including the 2.6.27.21-170.2.56.fc10.x86_64 I'm running right now=
. The
> > >>>> simple python script available here allows to see it quite easily :
> > >>>> https://www.redhat.com/archives/rhelv5-list/2009-February/msg00166=
.html
> > >>>>
> > >>>>  * I run the script on my Workstation, I have an FTP server enabled
> > >>>>  * I download a DVD ISO from a remote workstation : The values mat=
ch
> > >>>>  * I start ping floods from remote workstations : The values repor=
ted
> > >>>>    by /proc are much higher than the ones reported by tcpdump. I u=
sed
> > >>>>    "ping -s 500 -f myworkstation" from two remote workstations
> > >>>>
> > >>>> If there's anything flawed in my debugging, I'd love to have someo=
ne
> > >>>> point it out to me. TIA to anyone willing to have a look.
> > >>>>
> > >>>> Matthias
> > >>>>
> > >>> I could not reproduce this here... what kind of NIC are you using on
> > >>> affected systems ? Some ethernet drivers report stats from card its=
elf,
> > >>> and I remember seeing some strange stats on some hardware, but I ca=
nnot
> > >>> remember which one it was (we were reading NULL values instead of
> > >>> real ones, once in a while, maybe it was a firmware issue...)
> > >> My workstation has a Broadcom BCM5752 (tg3 module). The servers which
> > >> are most affected have Intel 82571EB (e1000e). But the issue is that
> > >> with /proc, the values are a lot _higher_ than with tcpdump, and the
> > >> tcpdump values seem to be the correct ones.
> > >=20
> > > the e1000 chip reports stats every 2 seconds. So you have to collect
> > > stats every 2 seconds otherwise you get "camel-looking" stats.
> > >=20
> >=20
> > I looked at e1000e driver, and apparently tx_packets & tx_bytes are com=
puted
> > by the TX completion routine, not by the chip.
>=20
> Ah I thought that was the chip which returned those stats every 2 seconds,
> otherwise I don't see the reason to delay their reporting. Wait, I'm spea=
king
> about e1000, never tried e1000e. Maybe there have been changes there. Any=
way,
> Matthias talked about RHEL5's 2.6.18 in which I don't think there was e10=
00e.
>=20
> Anyway we did not get any concrete data for now, so it's hard to tell (I
> haven't copy-pasted the links above in my browser yet).

If you need any more data, please just ask. What makes me wonder most,
though, is that tcpdump and iptraf report what seem to be correct
bandwidth values (they seem to use the same low level access for their
counters) whereas snmp and ifconfig (which seem to use /proc for
theirs) report unrealistically high values.

The tcpdump vs. /proc would be the first thing to look at, since it
might give hints as to where the problem might lie, no?

=46rom there, I could collect any data one might find relevant to
diagnose further.

I'm attaching the simple python script I've used for testing.

Matthias

--=20
Clean custom Red Hat Linux rpm packages : http://freshrpms.net/
Fedora release 10 (Cambridge) - Linux kernel
2.6.27.21-170.2.56.fc10.x86_64 Load : 0.19 0.15 0.05

--MP_/l6Kc96JmQ=e_4SXVT+=usdR
Content-Type: text/x-python
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=bandwidth-monitor.py

#!/usr/bin/python
import re
import time
import thread
import getopt
import signal
import sys
from subprocess import Popen, PIPE, STDOUT

# TODO print not refreshing correctly

def get_bytes_from_tcpdump(interface, src, byte_values):
    command = Popen(['tcpdump', '-n', '-e', '-p', '-l', '-v', '-i',
                     interface, 'src', src], stdout=PIPE, stderr=PIPE,
                     bufsize=0)
    while 1:
        line = command.stdout.readline()
        if not line:
            # time.sleep(1)
            continue
        bytes_pattern = re.search('length \d*', line)
        # dest_pattern = re.search('> .*: ', line)

        if bytes_pattern:
            s = bytes_pattern.group(0)
            bytes = int(s[7:]) + 5
        else:
            # ARP packet
            bytes = 28 + 14

        byte_values[0] += bytes
        byte_values[1] += 1
        # time.sleep(1)

        # if dest_pattern:
        #     s = dest_pattern.group()
        #     dest = s[2:len(s)-2]

def get_bytes_from_proc(interface, byte_values):
    wrap = 2**32
    offset = read_proc(interface)
    while(1):
        current_bytes = read_proc(interface)
        increase = current_bytes - offset
        if increase < 0:
            increase = (wrap - (byte_values[0] % wrap)) + current_bytes
        byte_values[0] += increase
        offset = current_bytes
        time.sleep(1)

def get_bytes_from_ifconfig(interface, byte_values):
    offset = read_ifconfig(interface)
    while(1):
        bytes = read_ifconfig(interface)
        byte_values[0] += (bytes - offset)
        offset = bytes
        time.sleep(1)

def read_ifconfig(interface):
    command = Popen(['/sbin/ifconfig', interface], stdout=PIPE, stderr=PIPE)
    # received bytes
    # lines = command.communicate()[0].split()[34]
    # transmitted bytes
    try:
        s = command.communicate()
    except Exception, e:
        print "failed: %r" % e
    bytes = int(s[0].split()[38].split(':')[1])
    return bytes

def read_proc(interface):
    f = open('/proc/net/dev')
    for line in f:
        values = line.split()
        i = values[0].split(':')[0]
        if interface == i:
            bytes = int(values[8])
            # received bytes
            # bytes = int(values[0].split(':')[1])
            f.close()
            return bytes
    f.close()

def signal_handler(signum, frame):
#    print "bye"
    sys.exit(0)

def main(interface, host):
    signal.signal(signal.SIGINT, signal_handler)

    byte_value_tcpdump = [0, 0]
    byte_value_proc = [0]
    byte_value_ifconfig = [0]

    thread.start_new_thread(get_bytes_from_tcpdump,
                            (interface, host, byte_value_tcpdump))
    thread.start_new_thread(get_bytes_from_proc, (interface, byte_value_proc))
    # thread.start_new_thread(get_bytes_from_ifconfig, (interface,
    #                                                   byte_value_ifconfig))

    while 1:
        s = "TCPDUMP: %d (%d packets)\nPROC:    %d" % (byte_value_tcpdump[0],
                                                       byte_value_tcpdump[1],
                                                       byte_value_proc[0])
        print s
        time.sleep(1)

def usage():
    print "Usage: monitor -i interface (e.g. eth0) -m host_ip"

if __name__ == "__main__":
    interface = None
    ip = None
    opts, args = getopt.getopt(sys.argv[1:], "hi:m:", ["help"])
    for o, a in opts:
        if o == '-i':
            interface = a
        elif o == '-m':
            ip = a
        elif o in ['-h', '--help']:
            usage()
            sys.exit()
    if not interface or not ip:
        usage()
        sys.exit()

    main(interface, ip)


--MP_/l6Kc96JmQ=e_4SXVT+=usdR--
