From: Niklas Edmundsson <Niklas.Edmundsson@hpc2n.umu.se>
Subject: martian packet checks breaks multi-homing
Date: Tue, 1 Jul 2003 09:37:26 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.56.0307010921100.5910@tekla.ing.umu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi!

We are setting up a multi homed server (currently running Linux
2.4.18) connected to several physical networks (due to the fact that
the server is a dhcp server too).

All clients talks to the main interface on the machine, routing is
done by the network equipment.

The problem is that when a client tries to talk to the main interface
of the server (not on the same network), the server tags the packets
as martian source and discards them! It's a perfectly valid packet
since the client is not even aware of the servers extra interface on
the network at this point and thus talks to the main interface via the
default gateway and the normal routing on the campus network.

This feature is desirable if you are doing some sort of routing or
firewalling when there are no reason to talk to the other interface,
but when doing multi-homing it's not what you want if you have an
environment where clients talks to a main interface of a machine to
establish communication (due to higher bandwidth or other reasons).

I haven't even been able to find a way to disable or circumvent the
check other than edit the source (fib_validate_source() is rather hard
to read by the way). It would be nice if there existed a runtime way
to disable it.

I have done this setup a number of times using Solaris and AIX boxes,
and it's a simple thing that really ought to work...


If things are unclear or I have forgotten/missed something just tell
me so and I'll try to clarify.


/Nikke
-- 
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 Niklas Edmundsson, Admin @ {acc,hpc2n,ing}.umu.se   |  nikke@hpc2n.umu.se
---------------------------------------------------------------------------
 Egotist: Thinks he's in the groove when he's in a rut
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
