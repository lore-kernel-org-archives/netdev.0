From: "Christopher K. Johnson" <ckjohnson@gwi.net>
Subject: IPsec tunnel mode bug - malformed, misaddressed packets
Date: Sun, 17 Oct 2004 07:52:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41725CF5.2010606@gwi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is an ipsec bug in FC2 kernel 2.6.8-1.521 for ipsec tunnel mode.
I have proven with a packet trace that some packets are
misaddressed.  Specifically it constructs a packet of the form:
 IP header1 | AH header | IP header2 | ESP
The IP header1 has an incorrect destination address of the host in the
remote tunneled subnet instead of the remote vpn partner, whereas IP
header2 has the correct destination address of the remote vpn partner.

For an host in local ipsec subnet contacting a web server in remote
ipsec subnet the initial syn and response of syn,ack are tunnelled
successfuly, but the encrypted ack goes out malformed as indicated above,
thus is never delivered.

Packet trace and setkey config are attached to bugzilla entry at 
http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=132832

Your help in resolving this bug so ipsec is usable would be appreciated greatly.

Chris
