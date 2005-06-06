From: Russell King <rmk@arm.linux.org.uk>
Subject: Fwd: [Bug 4615] Modem connection stalls out.
Date: Mon, 6 Jun 2005 22:47:29 +0100
Message-ID: <20050606224729.B12034@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anyone have any ideas on this bug?

The "No buffer space available" looks like the system is running low on
memory.  Would networking folk concur with that?

----- Forwarded message from bugme-daemon@kernel-bugs.osdl.org -----

Date: Mon, 6 Jun 2005 09:19:47 -0700
From: bugme-daemon@kernel-bugs.osdl.org
To: rmk@arm.linux.org.uk
Subject: [Bug 4615] Modem connection stalls out.

http://bugzilla.kernel.org/show_bug.cgi?id=4615





------- Additional Comments From alangrimes@starpower.net  2005-06-06 09:19 -------
The only reliable feedback I get from the bug, asside from its obvious symptoms,
is through ping... 

Here is a typical output: 

64 bytes from 10.65.28.26: icmp_seq=296 ttl=255 time=2552 ms
64 bytes from 10.65.28.26: icmp_seq=297 ttl=255 time=1561 ms
64 bytes from 10.65.28.26: icmp_seq=298 ttl=255 time=567 ms
64 bytes from 10.65.28.26: icmp_seq=299 ttl=255 time=137 ms
64 bytes from 10.65.28.26: icmp_seq=300 ttl=255 time=484 ms  # Hmm, exactly 5 
##  minutes, though I've seen it quit after only 10 seconds...) 
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
## It would have continued repeating this message indefinitely... 
## Note: many more iterations have been removed from this report!!! =P  

## Below is what happens when I manually disconnect the modem by sending 
## the break signal to the dialer. 
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable

--- 10.65.28.26 ping statistics ---
337 packets transmitted, 300 received, 10% packet loss, time 35529
5ms
rtt min/avg/max/mdev = 122.973/687.037/6298.163/1093.624 ms, pipe 
7
###################################

After power cycling the modem here's what the dialer does: 
leenooks ~ # wvdial
--> WvDial: Internet dialer version 1.54.0
--> Initializing modem.
--> Sending: ATZ
--> Sending: ATQ0
--> Re-Sending: ATZ 

### the dialer is hung and will report that the modem is not responding in a 
### few seconds...

### At this point I could ctrl-break the dialer and try again, 
### However, this would be entirely unproductive as I'd get the same mesage 
### each and every time.

### Only by allowing it to complete its cycle, will it return the modem to 
### functionality. I suspect that the dialer sends an IOCTL or something to the
### driver which clears the fault... 

--> Modem not responding.
leenooks ~ # wvdial
--> WvDial: Internet dialer version 1.54.0
--> Initializing modem.
--> Sending: ATZ
ATZ
OK
--> Sending: AT&F&D2&C1X4V1Q0S7=70W2\N3&K3S11=60
AT&F&D2&C1X4V1Q0S7=70W2\N3&K3S11=60
OK
--> Modem initialized.
--> Sending: ATDT7038298111
--> Waiting for carrier.
ATDT7038298111
CONNECT 49333
--> Carrier detected.  Waiting for prompt.
** Ascend TNT2.LNHVA.MD.RCN.NET Terminal Server **
Login: 
--> Looks like a login prompt.
--> Sending: alangrimes
alangrimes
Password: 
--> Looks like a password prompt.
--> Sending: (password)
    Entering PPP Session.
    IP address is 66.44.56.212
    MTU is 1006.
--> Looks like a welcome message.
--> Starting pppd at Tue Jun  7 04:58:30 2005
--> pid of pppd: 19733
--> Using interface ppp0
--> local  IP address 66.44.56.212
--> remote IP address 10.65.28.27
--> primary   DNS address 207.172.3.10
--> secondary DNS address 207.172.3.11

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

----- End forwarded message -----

-- 
Russell King
